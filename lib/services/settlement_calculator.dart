/// A single payment one person should make to another to settle up.
class Transfer {
  /// Creates a [Transfer].
  const Transfer({
    required this.fromPersonId,
    required this.toPersonId,
    required this.amount,
  });

  /// The person who should pay (a net debtor).
  final String fromPersonId;

  /// The person who should be paid (a net creditor).
  final String toPersonId;

  /// The amount to transfer, in currency units.
  final double amount;
}

/// Pure, stateless math that turns "who owes what" and "who paid what" into a
/// minimal list of person-to-person [Transfer]s that settles the bill.
class SettlementCalculator {
  /// Creates a [SettlementCalculator].
  const SettlementCalculator();

  /// Computes the transfers needed to settle up.
  ///
  /// [owed] maps `personId → amount owed` (from the split calculator); [paid]
  /// maps `personId → amount paid`. A person's net balance is
  /// `paid − owed`: positive means they fronted more than their share and
  /// should be paid back; negative means they still owe money.
  ///
  /// Uses a greedy largest-creditor/largest-debtor match, yielding at most
  /// `n − 1` transfers. All arithmetic is done in integer cents to avoid
  /// floating-point drift. If the totals do not balance (paid ≠ owed) the
  /// residual is left on a single party rather than fabricated away.
  List<Transfer> settle({
    required Map<String, double> owed,
    required Map<String, double> paid,
  }) {
    final Set<String> people = <String>{...owed.keys, ...paid.keys};

    // Net balance per person, in integer cents.
    final List<_Balance> creditors = <_Balance>[];
    final List<_Balance> debtors = <_Balance>[];
    for (final String id in people) {
      final int net = ((paid[id] ?? 0) * 100).round() -
          ((owed[id] ?? 0) * 100).round();
      if (net > 0) {
        creditors.add(_Balance(id, net));
      } else if (net < 0) {
        debtors.add(_Balance(id, -net));
      }
    }

    // Largest balances first so big debts are cleared in few transfers.
    creditors.sort((_Balance a, _Balance b) => b.cents.compareTo(a.cents));
    debtors.sort((_Balance a, _Balance b) => b.cents.compareTo(a.cents));

    final List<Transfer> transfers = <Transfer>[];
    int ci = 0;
    int di = 0;
    while (ci < creditors.length && di < debtors.length) {
      final _Balance creditor = creditors[ci];
      final _Balance debtor = debtors[di];
      final int amount =
          creditor.cents < debtor.cents ? creditor.cents : debtor.cents;

      transfers.add(Transfer(
        fromPersonId: debtor.personId,
        toPersonId: creditor.personId,
        amount: amount / 100.0,
      ));

      creditor.cents -= amount;
      debtor.cents -= amount;
      if (creditor.cents == 0) ci++;
      if (debtor.cents == 0) di++;
    }

    return transfers;
  }
}

/// A person's outstanding balance in integer cents, mutated while matching.
class _Balance {
  _Balance(this.personId, this.cents);

  final String personId;
  int cents;
}
