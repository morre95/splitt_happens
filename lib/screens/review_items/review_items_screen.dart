import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../app.dart';
import '../../core/money.dart';
import '../../models/bill.dart';
import '../../providers/bill_provider.dart';
import 'item_edit_tile.dart';

const Uuid _uuid = Uuid();

/// Editable list of parsed items with a totals summary and a validation
/// warning when the items no longer match the parsed subtotal.
class ReviewItemsScreen extends ConsumerWidget {
  /// Creates a [ReviewItemsScreen].
  const ReviewItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Bill? bill = ref.watch(billControllerProvider).valueOrNull;
    final BillController controller =
        ref.read(billControllerProvider.notifier);

    if (bill == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final double parsedSubtotal = controller.parsedSubtotal;
    final bool mismatch = parsedSubtotal > 0 &&
        (bill.subtotal - parsedSubtotal).abs() > 0.05;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review items'),
        actions: <Widget>[
          TextButton(
            onPressed: bill.items.isEmpty
                ? null
                : () => context.push(Routes.people),
            child: const Text('Next'),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (mismatch)
            _WarningBanner(
              text: 'Items total ${formatMoney(bill.subtotal, bill.currency)} '
                  'but the receipt subtotal was '
                  '${formatMoney(parsedSubtotal, bill.currency)}.',
            ),
          Expanded(
            child: bill.items.isEmpty
                ? const Center(child: Text('No items. Add one with “+”.'))
                : ListView.separated(
                    itemCount: bill.items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (BuildContext context, int index) {
                      final Item item = bill.items[index];
                      return Dismissible(
                        key: ValueKey<String>(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Theme.of(context).colorScheme.errorContainer,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Icon(Icons.delete),
                        ),
                        onDismissed: (_) => controller.removeItem(item.id),
                        child: ItemEditTile(
                          item: item,
                          currency: bill.currency,
                          onChanged: controller.updateItem,
                        ),
                      );
                    },
                  ),
          ),
          _SummaryRow(bill: bill, onEditTaxTip: () => _editTaxTip(context, ref)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.addItem(
          Item(id: _uuid.v4(), name: 'New item', unitPrice: 0),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _editTaxTip(BuildContext context, WidgetRef ref) async {
    final Bill bill = ref.read(billControllerProvider).requireValue;
    final TextEditingController taxCtrl =
        TextEditingController(text: bill.taxAmount.toStringAsFixed(2));
    final TextEditingController tipCtrl =
        TextEditingController(text: bill.tipAmount.toStringAsFixed(2));

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Edit tax & tip'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: taxCtrl,
              decoration: const InputDecoration(labelText: 'Tax'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: tipCtrl,
              decoration: const InputDecoration(labelText: 'Tip'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved ?? false) {
      ref.read(billControllerProvider.notifier).setTaxTip(
            double.tryParse(taxCtrl.text) ?? bill.taxAmount,
            double.tryParse(tipCtrl.text) ?? bill.tipAmount,
          );
    }
    taxCtrl.dispose();
    tipCtrl.dispose();
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.amber.shade100,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: <Widget>[
          Icon(Icons.warning_amber, color: Colors.amber.shade900),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.amber.shade900),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.bill, required this.onEditTaxTip});

  final Bill bill;
  final VoidCallback onEditTaxTip;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: onEditTaxTip,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              _line(context, 'Subtotal', bill.subtotal),
              _line(context, 'Tax', bill.taxAmount),
              _line(context, 'Tip', bill.tipAmount),
              const Divider(),
              _line(context, 'Total', bill.total, bold: true),
              const SizedBox(height: 4),
              Text(
                'Tap to edit tax & tip',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(BuildContext context, String label, double value,
      {bool bold = false}) {
    final TextStyle? style = bold
        ? Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: style),
          Text(formatMoney(value, bill.currency), style: style),
        ],
      ),
    );
  }
}
