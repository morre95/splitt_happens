import 'package:flutter/material.dart' hide Split;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../app.dart';
import '../../core/money.dart';
import '../../models/bill.dart';
import '../../providers/bill_provider.dart';
import '../../services/settlement_calculator.dart';
import '../../services/split_calculator.dart';
import 'person_summary_card.dart';
import 'settlement_section.dart';

/// Final per-person breakdown with grand total, plus share-as-text and
/// export-to-PDF actions.
class SummaryScreen extends ConsumerWidget {
  /// Creates a [SummaryScreen].
  const SummaryScreen({super.key});

  static const SplitCalculator _calculator = SplitCalculator();
  static const SettlementCalculator _settlement = SettlementCalculator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Bill? bill = ref.watch(billControllerProvider).valueOrNull;
    if (bill == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final Map<String, double> owed = _calculator.calculate(
      items: bill.items,
      splits: bill.splits,
      taxAmount: bill.taxAmount,
      tipAmount: bill.tipAmount,
    );
    final List<PersonBreakdown> breakdowns = _buildBreakdowns(bill, owed);
    final List<Transfer> transfers = _settlement.settle(
      owed: owed,
      paid: <String, double>{
        for (final Payment p in bill.payments) p.personId: p.amount,
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _editName(context, ref),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: Text(
                  bill.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.edit_outlined, size: 18),
            ],
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save bill',
            onPressed: () => _save(context, ref),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: <Widget>[
                ...breakdowns.map((PersonBreakdown b) =>
                    PersonSummaryCard(breakdown: b, currency: bill.currency)),
                SettlementSection(
                  transfers: transfers,
                  people: bill.people,
                  currency: bill.currency,
                  onAddPayments: () => context.push(Routes.payments),
                ),
              ],
            ),
          ),
          _GrandTotalBar(bill: bill),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _shareText(bill, breakdowns, transfers),
                      icon: const Icon(Icons.share),
                      label: const Text('Share as text'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _exportPdf(bill, breakdowns, transfers),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Export PDF'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Computes each person's item shares, prorated tax/tip, and final total.
  /// [totals] is the authoritative owed map from [SplitCalculator].
  List<PersonBreakdown> _buildBreakdowns(Bill bill, Map<String, double> totals) {
    final Map<String, Item> itemsById = <String, Item>{
      for (final Item i in bill.items) i.id: i,
    };

    final Map<String, List<PersonItemShare>> shares =
        <String, List<PersonItemShare>>{};
    final Map<String, double> subtotals = <String, double>{};
    for (final Split s in bill.splits) {
      final Item? item = itemsById[s.itemId];
      if (item == null || s.portionDenominator == 0) continue;
      final double amount =
          item.lineTotal * s.portionNumerator / s.portionDenominator;
      shares
          .putIfAbsent(s.personId, () => <PersonItemShare>[])
          .add(PersonItemShare(name: item.name, amount: amount));
      subtotals[s.personId] = (subtotals[s.personId] ?? 0) + amount;
    }

    final double totalSubtotal =
        subtotals.values.fold(0, (double a, double b) => a + b);

    return bill.people.map((Person person) {
      final double subtotal = subtotals[person.id] ?? 0;
      final double ratio = totalSubtotal == 0 ? 0 : subtotal / totalSubtotal;
      return PersonBreakdown(
        person: person,
        items: shares[person.id] ?? const <PersonItemShare>[],
        subtotal: subtotal,
        taxShare: bill.taxAmount * ratio,
        tipShare: bill.tipAmount * ratio,
        total: totals[person.id] ?? 0,
      );
    }).toList();
  }

  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final Bill bill = ref.read(billControllerProvider).requireValue;
    final String? name = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => _EditNameDialog(initialName: bill.name),
    );
    if (name != null && name.isNotEmpty) {
      ref.read(billControllerProvider.notifier).setName(name);
    }
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    await ref.read(billControllerProvider.notifier).save();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bill saved')),
    );
    context.go(Routes.home);
  }

  Future<void> _shareText(Bill bill, List<PersonBreakdown> breakdowns,
      List<Transfer> transfers) {
    final Map<String, Person> byId = <String, Person>{
      for (final Person p in bill.people) p.id: p,
    };
    final StringBuffer buffer = StringBuffer()
      ..writeln(bill.name)
      ..writeln('—' * 20);
    for (final PersonBreakdown b in breakdowns) {
      buffer.writeln(
        '${b.person.name}: ${formatMoney(b.total, bill.currency)}',
      );
    }
    buffer
      ..writeln('—' * 20)
      ..writeln('Total: ${formatMoney(bill.total, bill.currency)}');
    if (transfers.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Settle up:');
      for (final Transfer t in transfers) {
        buffer.writeln('${byId[t.fromPersonId]?.name ?? '?'} → '
            '${byId[t.toPersonId]?.name ?? '?'}: '
            '${formatMoney(t.amount, bill.currency)}');
      }
    }
    return Share.share(buffer.toString(), subject: bill.name);
  }

  Future<void> _exportPdf(Bill bill, List<PersonBreakdown> breakdowns,
      List<Transfer> transfers) {
    final Map<String, Person> byId = <String, Person>{
      for (final Person p in bill.people) p.id: p,
    };
    final pw.Document doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (pw.Context context) => <pw.Widget>[
          pw.Header(level: 0, text: bill.name),
          ...breakdowns.map((PersonBreakdown b) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text(
                      b.person.name,
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                    ...b.items.map((PersonItemShare s) => pw.Text(
                          '  ${s.name}: '
                          '${formatMoney(s.amount, bill.currency)}',
                        )),
                    pw.Text(
                      '  Tax: ${formatMoney(b.taxShare, bill.currency)}  '
                      'Tip: ${formatMoney(b.tipShare, bill.currency)}',
                    ),
                    pw.Text(
                      '  Total: ${formatMoney(b.total, bill.currency)}',
                      style:
                          pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              )),
          pw.Divider(),
          pw.Text(
            'Grand total: ${formatMoney(bill.total, bill.currency)}',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          if (transfers.isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 16),
            pw.Text(
              'Settle up',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            ...transfers.map((Transfer t) => pw.Text(
                  '${byId[t.fromPersonId]?.name ?? '?'} → '
                  '${byId[t.toPersonId]?.name ?? '?'}: '
                  '${formatMoney(t.amount, bill.currency)}',
                )),
          ],
        ],
      ),
    );
    return Printing.layoutPdf(
      onLayout: (PdfPageFormat format) => doc.save(),
      name: '${bill.name}.pdf',
    );
  }
}

class _GrandTotalBar extends StatelessWidget {
  const _GrandTotalBar({required this.bill});

  final Bill bill;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Grand total', style: theme.textTheme.titleMedium),
            Text(
              formatMoney(bill.total, bill.currency),
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for renaming the bill. Owns its [TextEditingController] so it is
/// disposed with the dialog route, and returns the trimmed name, or `null` on
/// cancel.
class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.initialName});

  final String initialName;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _name =
      TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_name.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename bill'),
      content: TextField(
        controller: _name,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(labelText: 'Bill name'),
        onSubmitted: (_) => _submit(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
