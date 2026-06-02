import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../models/bill.dart';
import '../../services/settlement_calculator.dart';

/// A card listing the minimal set of person-to-person transfers needed to
/// settle the bill ("who owes whom"), or an empty state prompting the user to
/// record payments.
class SettlementSection extends StatelessWidget {
  /// Creates a [SettlementSection].
  const SettlementSection({
    required this.transfers,
    required this.people,
    required this.currency,
    required this.onAddPayments,
    super.key,
  });

  /// The transfers to display.
  final List<Transfer> transfers;

  /// All people on the bill, used to resolve names and avatars.
  final List<Person> people;

  /// Currency code for formatting amounts.
  final String currency;

  /// Called when the user taps to add/edit payments.
  final VoidCallback onAddPayments;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Map<String, Person> byId = <String, Person>{
      for (final Person p in people) p.id: p,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Settle up', style: theme.textTheme.titleMedium),
                TextButton(
                  onPressed: onAddPayments,
                  child: const Text('Edit payments'),
                ),
              ],
            ),
            if (transfers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No payments recorded yet — add who paid to see who owes whom.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              )
            else
              ...transfers.map((Transfer t) => _row(context, byId, t)),
          ],
        ),
      ),
    );
  }

  Widget _row(
      BuildContext context, Map<String, Person> byId, Transfer transfer) {
    final Person? from = byId[transfer.fromPersonId];
    final Person? to = byId[transfer.toPersonId];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          _avatar(from),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(text: from?.name ?? '?'),
                  const TextSpan(text: '  →  '),
                  TextSpan(text: to?.name ?? '?'),
                ],
              ),
            ),
          ),
          Text(
            formatMoney(transfer.amount, currency),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _avatar(Person? person) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: person?.avatarColor ?? Colors.grey,
      child: Text(
        person == null || person.name.trim().isEmpty
            ? '?'
            : person.name.trim()[0].toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}
