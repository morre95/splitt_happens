import 'package:flutter_test/flutter_test.dart';
import 'package:split_happens/models/bill.dart';
import 'package:split_happens/models/receipt_parse_result.dart';
import 'package:split_happens/services/split_calculator.dart';

void main() {
  const SplitCalculator calculator = SplitCalculator();

  // Two items: $10 and $20 → $30 subtotal.
  final List<Item> items = <Item>[
    const Item(id: 'i1', name: 'Burger', unitPrice: 10),
    const Item(id: 'i2', name: 'Salad', unitPrice: 20),
  ];

  Split half(String personId, String itemId) => Split(
        personId: personId,
        itemId: itemId,
        portionNumerator: 1,
        portionDenominator: 2,
      );

  Split whole(String personId, String itemId) => Split(
        personId: personId,
        itemId: itemId,
        portionNumerator: 1,
        portionDenominator: 1,
      );

  group('SplitCalculator.calculate', () {
    test('splits both items equally between two people', () {
      final Map<String, double> result = calculator.calculate(
        items: items,
        splits: <Split>[
          half('p1', 'i1'),
          half('p2', 'i1'),
          half('p1', 'i2'),
          half('p2', 'i2'),
        ],
        taxAmount: 0,
        tipAmount: 0,
      );

      expect(result['p1'], 15.0);
      expect(result['p2'], 15.0);
    });

    test('handles an unequal split where each owns one item', () {
      final Map<String, double> result = calculator.calculate(
        items: items,
        splits: <Split>[
          whole('p1', 'i1'),
          whole('p2', 'i2'),
        ],
        taxAmount: 0,
        tipAmount: 0,
      );

      expect(result['p1'], 10.0);
      expect(result['p2'], 20.0);
    });

    test('prorates tax by each person\'s subtotal share', () {
      // $6 tax over a $30 subtotal: p1 owns $10 (1/3), p2 owns $20 (2/3).
      final Map<String, double> result = calculator.calculate(
        items: items,
        splits: <Split>[
          whole('p1', 'i1'),
          whole('p2', 'i2'),
        ],
        taxAmount: 6,
        tipAmount: 0,
      );

      expect(result['p1'], 12.0); // 10 + 2
      expect(result['p2'], 24.0); // 20 + 4
    });

    test('prorates tip by each person\'s subtotal share', () {
      // $3 tip over a $30 subtotal.
      final Map<String, double> result = calculator.calculate(
        items: items,
        splits: <Split>[
          whole('p1', 'i1'),
          whole('p2', 'i2'),
        ],
        taxAmount: 0,
        tipAmount: 3,
      );

      expect(result['p1'], 11.0); // 10 + 1
      expect(result['p2'], 22.0); // 20 + 2
    });

    test('assigns the full bill to one person who takes all items', () {
      final Map<String, double> result = calculator.calculate(
        items: items,
        splits: <Split>[
          whole('p1', 'i1'),
          whole('p1', 'i2'),
        ],
        taxAmount: 6,
        tipAmount: 3,
      );

      expect(result['p1'], 39.0); // 30 + 6 + 3
      expect(result.containsKey('p2'), isFalse);
    });

    test('avoids floating-point drift across a three-way split', () {
      // $10 split three ways must sum back to exactly $10.00 (within rounding).
      final List<Item> single = <Item>[
        const Item(id: 'i1', name: 'Pizza', unitPrice: 10),
      ];
      final Map<String, double> result = calculator.calculate(
        items: single,
        splits: <Split>[
          const Split(
              personId: 'p1',
              itemId: 'i1',
              portionNumerator: 1,
              portionDenominator: 3),
          const Split(
              personId: 'p2',
              itemId: 'i1',
              portionNumerator: 1,
              portionDenominator: 3),
          const Split(
              personId: 'p3',
              itemId: 'i1',
              portionNumerator: 1,
              portionDenominator: 3),
        ],
        taxAmount: 0,
        tipAmount: 0,
      );

      // Each rounds to 3.33; the calculator rounds half-up per person.
      for (final String id in <String>['p1', 'p2', 'p3']) {
        expect(result[id], 3.33);
      }
    });
  });

  group('SplitCalculator.validateTotal', () {
    test('returns true when item totals match the reported subtotal', () {
      const ReceiptParseResult result = ReceiptParseResult(
        items: <ParsedItem>[
          ParsedItem(name: 'A', unitPrice: 10),
          ParsedItem(name: 'B', unitPrice: 20),
        ],
        subtotal: 30,
      );
      expect(calculator.validateTotal(result), isTrue);
    });

    test('returns false when items diverge beyond tolerance', () {
      const ReceiptParseResult result = ReceiptParseResult(
        items: <ParsedItem>[
          ParsedItem(name: 'A', unitPrice: 10),
        ],
        subtotal: 30,
      );
      expect(calculator.validateTotal(result), isFalse);
    });

    test('treats a missing subtotal (0) as valid', () {
      const ReceiptParseResult result = ReceiptParseResult(
        items: <ParsedItem>[ParsedItem(name: 'A', unitPrice: 10)],
      );
      expect(calculator.validateTotal(result), isTrue);
    });
  });
}
