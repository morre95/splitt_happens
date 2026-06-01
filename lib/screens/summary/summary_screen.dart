import 'package:flutter/material.dart' hide Split;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/money.dart';
import '../../models/bill.dart';
import '../../providers/bill_provider.dart';
import '../../services/split_calculator.dart';
import 'person_summary_card.dart';

/// Final per-person breakdown with grand total, plus share-as-text and
/// export-to-PDF actions.
class SummaryScreen extends ConsumerWidget {
  /// Creates a [SummaryScreen].
  const SummaryScreen({super.key});

  static const SplitCalculator _calculator = SplitCalculator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Bill? bill = ref.watch(billControllerProvider).valueOrNull;
    if (bill == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<PersonBreakdown> breakdowns = _buildBreakdowns(bill);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
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
              children: breakdowns
                  .map((PersonBreakdown b) =>
                      PersonSummaryCard(breakdown: b, currency: bill.currency))
                  .toList(),
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
                          _shareText(bill, breakdowns),
                      icon: const Icon(Icons.share),
                      label: const Text('Share as text'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _exportPdf(bill, breakdowns),
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
  List<PersonBreakdown> _buildBreakdowns(Bill bill) {
    final Map<String, double> totals = _calculator.calculate(
      items: bill.items,
      splits: bill.splits,
      taxAmount: bill.taxAmount,
      tipAmount: bill.tipAmount,
    );
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

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    await ref.read(billControllerProvider.notifier).save();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bill saved')),
    );
  }

  Future<void> _shareText(Bill bill, List<PersonBreakdown> breakdowns) {
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
    return Share.share(buffer.toString(), subject: bill.name);
  }

  Future<void> _exportPdf(Bill bill, List<PersonBreakdown> breakdowns) {
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
