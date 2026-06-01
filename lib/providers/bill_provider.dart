import 'dart:io';

import 'package:flutter/material.dart' hide Split;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/daos/bill_dao.dart';
import '../models/bill.dart';
import '../models/receipt_parse_result.dart';
import '../services/receipt_parser_service.dart';
import 'ocr_provider.dart';
import 'settings_provider.dart';

part 'bill_provider.g.dart';

const Uuid _uuid = Uuid();

/// Palette cycled through when assigning avatar colours to new people.
const List<Color> _avatarPalette = <Color>[
  Color(0xFF6750A4),
  Color(0xFF2E7D32),
  Color(0xFFC62828),
  Color(0xFF1565C0),
  Color(0xFFEF6C00),
  Color(0xFF00838F),
  Color(0xFFAD1457),
  Color(0xFF4527A0),
];

/// Provides the singleton [AppDatabase].
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final AppDatabase db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

/// Provides the [BillDao].
@Riverpod(keepAlive: true)
BillDao billDao(Ref ref) => ref.watch(appDatabaseProvider).billDao;

/// Streams the list of saved bills, most recent first.
@riverpod
Future<List<Bill>> savedBills(Ref ref) {
  return ref.watch(billDaoProvider).getAllBills();
}

/// Drives a single receipt-splitting session through its lifecycle:
/// `idle → scanning → reviewing → assigning → summarised`.
///
/// Stages map onto the exposed [currentBill]:
/// * **scanning** — `AsyncLoading` while OCR + LLM parsing run;
/// * **reviewing / assigning / summarised** — `AsyncData`, distinguished by
///   the active route;
/// * pipeline failures surface as `AsyncError`.
@riverpod
class BillController extends _$BillController {
  double _parsedSubtotal = 0;

  /// The subtotal the LLM reported for the most recent scan, used by the
  /// review screen to warn when edited items no longer add up. Zero when no
  /// scan reference is available (e.g. a manually built or loaded bill).
  double get parsedSubtotal => _parsedSubtotal;

  @override
  FutureOr<Bill> build() => _emptyBill();

  Bill _emptyBill() => Bill(
        id: _uuid.v4(),
        name: 'New bill',
        date: DateTime.now(),
      );

  /// Starts a fresh bill (called before navigating to the scan screen).
  void reset() {
    _parsedSubtotal = 0;
    state = AsyncData<Bill>(_emptyBill());
  }

  /// Loads an existing [bill] into the controller (e.g. to view a saved bill).
  void load(Bill bill) {
    _parsedSubtotal = 0;
    state = AsyncData<Bill>(bill);
  }

  /// Runs the OCR + LLM parse pipeline on [image] and populates the bill with
  /// the extracted items. Surfaces failures through [currentBill].
  Future<void> startScan(File image) async {
    state = const AsyncLoading<Bill>();
    state = await AsyncValue.guard<Bill>(() async {
      final AppSettings settings = await ref.read(settingsProvider.future);
      final String ocrText = await ref.read(ocrTextProvider(image).future);
      final ReceiptParserService parser =
          ReceiptParserService(model: settings.model);
      final ReceiptParseResult parsed =
          await parser.parse(ocrText, settings.apiKey);
      _parsedSubtotal = parsed.subtotal;

      final List<Item> items = parsed.items
          .map((ParsedItem p) => Item(
                id: _uuid.v4(),
                name: p.name,
                quantity: p.quantity,
                unitPrice: p.unitPrice,
              ))
          .toList();

      return _emptyBill().copyWith(
        items: items,
        taxAmount: parsed.tax,
        tipAmount: parsed.tip,
        currency: settings.currency,
      );
    });
  }

  Bill? get _bill => state.valueOrNull;

  void _set(Bill bill) => state = AsyncData<Bill>(bill);

  /// Adds a new manual item to the bill.
  void addItem(Item item) {
    final Bill? bill = _bill;
    if (bill == null) return;
    _set(bill.copyWith(items: <Item>[...bill.items, item]));
  }

  /// Replaces an existing item (matched by id) with [item].
  void updateItem(Item item) {
    final Bill? bill = _bill;
    if (bill == null) return;
    _set(bill.copyWith(
      items: bill.items
          .map((Item i) => i.id == item.id ? item : i)
          .toList(),
    ));
  }

  /// Removes the item with [itemId] and any splits referencing it.
  void removeItem(String itemId) {
    final Bill? bill = _bill;
    if (bill == null) return;
    _set(bill.copyWith(
      items: bill.items.where((Item i) => i.id != itemId).toList(),
      splits:
          bill.splits.where((Split s) => s.itemId != itemId).toList(),
    ));
  }

  /// Adds a person with the given [name], assigning the next palette colour.
  void addPerson(String name) {
    final Bill? bill = _bill;
    if (bill == null) return;
    final Color color =
        _avatarPalette[bill.people.length % _avatarPalette.length];
    final Person person =
        Person(id: _uuid.v4(), name: name, avatarColor: color);
    _set(bill.copyWith(people: <Person>[...bill.people, person]));
  }

  /// Removes the person with [id] and any splits they own, rebalancing the
  /// affected items.
  void removePerson(String id) {
    final Bill? bill = _bill;
    if (bill == null) return;
    final List<Split> remaining =
        bill.splits.where((Split s) => s.personId != id).toList();
    _set(bill.copyWith(
      people: bill.people.where((Person p) => p.id != id).toList(),
      splits: _rebalanceAll(remaining),
    ));
  }

  /// Toggles whether [personId] shares the item [itemId]. When [shared] is
  /// true the person is added to the item's sharers; otherwise removed. The
  /// item's portions are then rebalanced to equal fractions.
  void assignItem(String itemId, String personId, bool shared) {
    final Bill? bill = _bill;
    if (bill == null) return;
    final List<Split> others =
        bill.splits.where((Split s) => s.itemId != itemId).toList();
    final Set<String> sharers = bill.splits
        .where((Split s) => s.itemId == itemId)
        .map((Split s) => s.personId)
        .toSet();

    if (shared) {
      sharers.add(personId);
    } else {
      sharers.remove(personId);
    }

    _set(bill.copyWith(
      splits: <Split>[...others, ..._equalSplits(itemId, sharers)],
    ));
  }

  /// Sets an explicit [split], replacing any existing split for the same
  /// item/person pair.
  void setSplit(Split split) {
    final Bill? bill = _bill;
    if (bill == null) return;
    final List<Split> others = bill.splits
        .where((Split s) =>
            !(s.itemId == split.itemId && s.personId == split.personId))
        .toList();
    _set(bill.copyWith(splits: <Split>[...others, split]));
  }

  /// Assigns every item equally to every person.
  void splitEqually() {
    final Bill? bill = _bill;
    if (bill == null) return;
    final Set<String> everyone =
        bill.people.map((Person p) => p.id).toSet();
    final List<Split> splits = <Split>[
      for (final Item item in bill.items)
        ..._equalSplits(item.id, everyone),
    ];
    _set(bill.copyWith(splits: splits));
  }

  /// Sets the bill's [tax] and [tip] amounts.
  void setTaxTip(double tax, double tip) {
    final Bill? bill = _bill;
    if (bill == null) return;
    _set(bill.copyWith(taxAmount: tax, tipAmount: tip));
  }

  /// Sets the bill's display [name].
  void setName(String name) {
    final Bill? bill = _bill;
    if (bill == null) return;
    _set(bill.copyWith(name: name));
  }

  /// Persists the current bill and refreshes the saved-bills list.
  Future<void> save() async {
    final Bill? bill = _bill;
    if (bill == null) return;
    await ref.read(billDaoProvider).saveBill(bill);
    ref.invalidate(savedBillsProvider);
  }

  /// The current bill state, exposed for the UI.
  AsyncValue<Bill> get currentBill => state;

  List<Split> _equalSplits(String itemId, Set<String> personIds) {
    if (personIds.isEmpty) return const <Split>[];
    final int denominator = personIds.length;
    return personIds
        .map((String personId) => Split(
              personId: personId,
              itemId: itemId,
              portionNumerator: 1,
              portionDenominator: denominator,
            ))
        .toList();
  }

  /// Re-derives equal splits for every item from the surviving [splits].
  List<Split> _rebalanceAll(List<Split> splits) {
    final Map<String, Set<String>> byItem = <String, Set<String>>{};
    for (final Split s in splits) {
      byItem.putIfAbsent(s.itemId, () => <String>{}).add(s.personId);
    }
    return <Split>[
      for (final MapEntry<String, Set<String>> e in byItem.entries)
        ..._equalSplits(e.key, e.value),
    ];
  }
}
