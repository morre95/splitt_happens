import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/money.dart';
import '../../models/bill.dart';
import '../../providers/bill_provider.dart';
import '../../widgets/warning_banner.dart';
import 'payment_entry_tile.dart';

/// Records how much each person actually paid towards the bill, so the summary
/// can settle up who owes whom.
class PaymentsScreen extends ConsumerWidget {
  /// Creates a [PaymentsScreen].
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Bill? bill = ref.watch(billControllerProvider).valueOrNull;
    if (bill == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final BillController controller =
        ref.read(billControllerProvider.notifier);

    final Map<String, double> paidByPerson = <String, double>{
      for (final Payment p in bill.payments) p.personId: p.amount,
    };
    final bool unbalanced = (bill.totalPaid - bill.total).abs() > 0.01;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Who paid?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => context.push(Routes.summary),
            child: const Text('Settle up'),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (unbalanced)
            WarningBanner(
              text: 'Payments total ${formatMoney(bill.totalPaid, bill.currency)} '
                  'but the bill is ${formatMoney(bill.total, bill.currency)}.',
            ),
          Expanded(
            child: bill.people.isEmpty
                ? const Center(child: Text('Add people first.'))
                : ListView.separated(
                    itemCount: bill.people.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (BuildContext context, int index) {
                      final Person person = bill.people[index];
                      return PaymentEntryTile(
                        person: person,
                        amount: paidByPerson[person.id] ?? 0,
                        currency: bill.currency,
                        onChanged: (double amount) =>
                            controller.setPayment(person.id, amount),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _PaidSummaryBar(bill: bill),
    );
  }
}

class _PaidSummaryBar extends StatelessWidget {
  const _PaidSummaryBar({required this.bill});

  final Bill bill;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double remaining = bill.total - bill.totalPaid;
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _line(context, 'Total paid', bill.totalPaid),
            _line(context, 'Bill total', bill.total),
            const Divider(),
            _line(context, 'Unaccounted', remaining, bold: true),
          ],
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
