import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/bill.dart';

/// An inline-editable row for one [Item]: name, quantity, and unit price.
class ItemEditTile extends StatefulWidget {
  /// Creates an [ItemEditTile].
  const ItemEditTile({
    required this.item,
    required this.currency,
    required this.onChanged,
    super.key,
  });

  /// The item being edited.
  final Item item;

  /// Currency code (used as the price field prefix).
  final String currency;

  /// Called with the updated item whenever a field changes.
  final ValueChanged<Item> onChanged;

  @override
  State<ItemEditTile> createState() => _ItemEditTileState();
}

class _ItemEditTileState extends State<ItemEditTile> {
  late final TextEditingController _name;
  late final TextEditingController _quantity;
  late final TextEditingController _price;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.item.name);
    _quantity = TextEditingController(text: _trim(widget.item.quantity));
    _price = TextEditingController(text: widget.item.unitPrice.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    _price.dispose();
    super.dispose();
  }

  String _trim(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';

  void _emit() {
    widget.onChanged(
      widget.item.copyWith(
        name: _name.text.trim(),
        quantity: double.tryParse(_quantity.text) ?? widget.item.quantity,
        unitPrice: double.tryParse(_price.text) ?? widget.item.unitPrice,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 5,
            child: TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Item',
                isDense: true,
              ),
              onChanged: (_) => _emit(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _quantity,
              decoration: const InputDecoration(
                labelText: 'Qty',
                isDense: true,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              onChanged: (_) => _emit(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _price,
              decoration: const InputDecoration(
                labelText: 'Price',
                isDense: true,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              onChanged: (_) => _emit(),
            ),
          ),
        ],
      ),
    );
  }
}
