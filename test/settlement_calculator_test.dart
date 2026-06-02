import 'package:flutter_test/flutter_test.dart';
import 'package:split_happens/services/settlement_calculator.dart';

void main() {
  const SettlementCalculator calculator = SettlementCalculator();

  /// Net of every transfer per person (positive = received, negative = paid).
  Map<String, double> netOf(List<Transfer> transfers) {
    final Map<String, double> net = <String, double>{};
    for (final Transfer t in transfers) {
      net[t.fromPersonId] = (net[t.fromPersonId] ?? 0) - t.amount;
      net[t.toPersonId] = (net[t.toPersonId] ?? 0) + t.amount;
    }
    return net;
  }

  group('SettlementCalculator.settle', () {
    test('single payer covered the whole bill', () {
      // p1 paid $60 for everyone; each owes $20.
      final List<Transfer> transfers = calculator.settle(
        owed: <String, double>{'p1': 20, 'p2': 20, 'p3': 20},
        paid: <String, double>{'p1': 60},
      );

      // Two debtors each send p1 their $20 share.
      expect(transfers.length, 2);
      expect(transfers.every((Transfer t) => t.toPersonId == 'p1'), isTrue);
      final Map<String, double> net = netOf(transfers);
      expect(net['p1'], 40); // got back what they fronted beyond own share
      expect(net['p2'], -20);
      expect(net['p3'], -20);
    });

    test('multiple payers with mixed balances all net to zero', () {
      // Bill $90, owed equally ($30 each). p1 paid $90, p2 paid $0, p3 paid $0.
      final List<Transfer> transfers = calculator.settle(
        owed: <String, double>{'p1': 30, 'p2': 30, 'p3': 30},
        paid: <String, double>{'p1': 50, 'p2': 40, 'p3': 0},
      );

      final Map<String, double> net = netOf(transfers);
      // p1 fronted +20, p2 fronted +10, p3 owes 30.
      expect(net['p1'], 20);
      expect(net['p2'], 10);
      expect(net['p3'], -30);
    });

    test('everyone paid exactly their share needs no transfers', () {
      final List<Transfer> transfers = calculator.settle(
        owed: <String, double>{'p1': 25, 'p2': 25},
        paid: <String, double>{'p1': 25, 'p2': 25},
      );
      expect(transfers, isEmpty);
    });

    test('uneven amounts still balance to the cent', () {
      // $10 split 3 ways → 3.34 / 3.33 / 3.33; p1 paid it all.
      final List<Transfer> transfers = calculator.settle(
        owed: <String, double>{'p1': 3.34, 'p2': 3.33, 'p3': 3.33},
        paid: <String, double>{'p1': 10},
      );
      final Map<String, double> net = netOf(transfers);
      expect(net['p2'], closeTo(-3.33, 1e-9));
      expect(net['p3'], closeTo(-3.33, 1e-9));
      expect(net['p1'], closeTo(6.66, 1e-9));
    });

    test('produces at most n-1 transfers', () {
      final List<Transfer> transfers = calculator.settle(
        owed: <String, double>{'p1': 10, 'p2': 10, 'p3': 10, 'p4': 10},
        paid: <String, double>{'p1': 40},
      );
      expect(transfers.length, lessThanOrEqualTo(3));
    });

    test('empty input yields no transfers', () {
      expect(
        calculator.settle(owed: <String, double>{}, paid: <String, double>{}),
        isEmpty,
      );
    });
  });
}
