import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../models/bill.dart';

/// A summary card for a saved [Bill] shown in the home list.
class BillCardWidget extends StatelessWidget {
  /// Creates a [BillCardWidget].
  const BillCardWidget({
    required this.bill,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  /// The bill to display.
  final Bill bill;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  /// Called when the user chooses to delete this bill.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: const Icon(Icons.receipt_long),
        ),
        title: Text(bill.name),
        subtitle: Text(
          '${_formatDate(bill.date)} • ${bill.people.length} people',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              formatMoney(bill.total, bill.currency),
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${_pad(date.month)}-${_pad(date.day)}';

  String _pad(int value) => value.toString().padLeft(2, '0');
}
