import 'package:drift/drift.dart';
import 'package:flutter/material.dart' hide Split;

import '../../models/bill.dart';
import '../app_database.dart';

part 'bill_dao.g.dart';

/// Data-access object for reading and writing complete [Bill] aggregates
/// (the bill plus its items, people, and splits).
@DriftAccessor(tables: <Type>[Bills, Items, People, Splits])
class BillDao extends DatabaseAccessor<AppDatabase> with _$BillDaoMixin {
  /// Creates a [BillDao] bound to [db].
  BillDao(super.db);

  /// Inserts or replaces [bill] and all of its children atomically.
  Future<void> saveBill(Bill bill) {
    return transaction(() async {
      await into(bills).insertOnConflictUpdate(_billToRow(bill));

      await (delete(items)..where((Items t) => t.billId.equals(bill.id))).go();
      await (delete(people)..where((People t) => t.billId.equals(bill.id)))
          .go();
      await (delete(splits)..where((Splits t) => t.billId.equals(bill.id)))
          .go();

      await batch((Batch batch) {
        batch.insertAll(
          items,
          bill.items.map((Item i) => _itemToRow(bill.id, i)),
        );
        batch.insertAll(
          people,
          bill.people.map((Person person) => _personToRow(bill.id, person)),
        );
        batch.insertAll(
          splits,
          bill.splits.map((Split s) => _splitToRow(bill.id, s)),
        );
      });
    });
  }

  /// Returns all saved bills, most recent first.
  Future<List<Bill>> getAllBills() async {
    final List<BillRow> rows = await (select(bills)
          ..orderBy(<OrderingTerm Function($BillsTable)>[
            (Bills t) => OrderingTerm.desc(t.date),
          ]))
        .get();
    return Future.wait(rows.map((BillRow row) => _assembleBill(row)));
  }

  /// Returns the bill with [id], or `null` if it does not exist.
  Future<Bill?> getBill(String id) async {
    final BillRow? row =
        await (select(bills)..where((Bills t) => t.id.equals(id)))
            .getSingleOrNull();
    if (row == null) return null;
    return _assembleBill(row);
  }

  /// Deletes the bill with [id] and all of its children.
  Future<void> deleteBill(String id) {
    return transaction(() async {
      await (delete(splits)..where((Splits t) => t.billId.equals(id))).go();
      await (delete(items)..where((Items t) => t.billId.equals(id))).go();
      await (delete(people)..where((People t) => t.billId.equals(id))).go();
      await (delete(bills)..where((Bills t) => t.id.equals(id))).go();
    });
  }

  Future<Bill> _assembleBill(BillRow row) async {
    final List<ItemRow> itemRows =
        await (select(items)..where((Items t) => t.billId.equals(row.id)))
            .get();
    final List<PersonRow> peopleRows =
        await (select(people)..where((People t) => t.billId.equals(row.id)))
            .get();
    final List<SplitRow> splitRows =
        await (select(splits)..where((Splits t) => t.billId.equals(row.id)))
            .get();

    return Bill(
      id: row.id,
      name: row.name,
      date: row.date,
      taxAmount: row.taxAmount,
      tipAmount: row.tipAmount,
      currency: row.currency,
      items: itemRows
          .map((ItemRow i) => Item(
                id: i.id,
                name: i.name,
                quantity: i.quantity,
                unitPrice: i.unitPrice,
              ))
          .toList(),
      people: peopleRows
          .map((PersonRow person) => Person(
                id: person.id,
                name: person.name,
                avatarColor: Color(person.avatarColor),
              ))
          .toList(),
      splits: splitRows
          .map((SplitRow s) => Split(
                personId: s.personId,
                itemId: s.itemId,
                portionNumerator: s.portionNumerator,
                portionDenominator: s.portionDenominator,
              ))
          .toList(),
    );
  }

  BillsCompanion _billToRow(Bill bill) => BillsCompanion.insert(
        id: bill.id,
        name: bill.name,
        date: bill.date,
        taxAmount: Value<double>(bill.taxAmount),
        tipAmount: Value<double>(bill.tipAmount),
        currency: Value<String>(bill.currency),
      );

  ItemsCompanion _itemToRow(String billId, Item item) => ItemsCompanion.insert(
        id: item.id,
        billId: billId,
        name: item.name,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
      );

  PeopleCompanion _personToRow(String billId, Person person) =>
      PeopleCompanion.insert(
        id: person.id,
        billId: billId,
        name: person.name,
        avatarColor: person.avatarColor.toARGB32(),
      );

  SplitsCompanion _splitToRow(String billId, Split split) =>
      SplitsCompanion.insert(
        id: '$billId:${split.itemId}:${split.personId}',
        billId: billId,
        itemId: split.itemId,
        personId: split.personId,
        portionNumerator: split.portionNumerator,
        portionDenominator: split.portionDenominator,
      );
}
