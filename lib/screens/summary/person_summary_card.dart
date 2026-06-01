import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../models/bill.dart';

/// One person's share of a single item.
class PersonItemShare {
  /// Creates a [PersonItemShare].
  const PersonItemShare({required this.name, required this.amount});

  /// The item's display name.
  final String name;

  /// The amount this person owes for the item.
  final double amount;
}

/// A fully computed breakdown of what one [Person] owes.
class PersonBreakdown {
  /// Creates a [PersonBreakdown].
  const PersonBreakdown({
    required this.person,
    required this.items,
    required this.subtotal,
    required this.taxShare,
    required this.tipShare,
    required this.total,
  });

  /// The person this breakdown is for.
  final Person person;

  /// Per-item shares assigned to this person.
  final List<PersonItemShare> items;

  /// Sum of this person's item shares.
  final double subtotal;

  /// This person's prorated tax.
  final double taxShare;

  /// This person's prorated tip.
  final double tipShare;

  /// Final amount owed (authoritative, from the split calculator).
  final double total;
}

/// Card showing a single person's items, prorated tax/tip, and bold total.
class PersonSummaryCard extends StatelessWidget {
  /// Creates a [PersonSummaryCard].
  const PersonSummaryCard({
    required this.breakdown,
    required this.currency,
    super.key,
  });

  /// The breakdown to render.
  final PersonBreakdown breakdown;

  /// Currency code for formatting.
  final String currency;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: breakdown.person.avatarColor,
                  child: Text(
                    _initial(breakdown.person.name),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  breakdown.person.name,
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (breakdown.items.isEmpty)
              Text(
                'No items assigned',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontStyle: FontStyle.italic),
              )
            else
              ...breakdown.items.map(
                (PersonItemShare share) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(child: Text(share.name)),
                      Text(formatMoney(share.amount, currency)),
                    ],
                  ),
                ),
              ),
            const Divider(),
            _miniLine(context, 'Subtotal', breakdown.subtotal),
            _miniLine(context, 'Tax', breakdown.taxShare),
            _miniLine(context, 'Tip', breakdown.tipShare),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Total', style: theme.textTheme.titleMedium),
                Text(
                  formatMoney(breakdown.total, currency),
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniLine(BuildContext context, String label, double value) {
    final TextStyle? style = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.outline);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: style),
        Text(formatMoney(value, currency), style: style),
      ],
    );
  }

  String _initial(String name) =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}
