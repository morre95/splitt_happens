import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/bill.dart';

/// A row for entering how much one [Person] paid: their coloured avatar and
/// name beside an inline amount field.
class PaymentEntryTile extends StatefulWidget {
  /// Creates a [PaymentEntryTile].
  const PaymentEntryTile({
    required this.person,
    required this.amount,
    required this.currency,
    required this.onChanged,
    super.key,
  });

  /// The person who paid.
  final Person person;

  /// The amount currently recorded for this person.
  final double amount;

  /// Currency code (used as the amount field prefix).
  final String currency;

  /// Called with the parsed amount whenever the field changes.
  final ValueChanged<double> onChanged;

  @override
  State<PaymentEntryTile> createState() => _PaymentEntryTileState();
}

class _PaymentEntryTileState extends State<PaymentEntryTile> {
  late final TextEditingController _amount;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(
      text: widget.amount == 0 ? '' : widget.amount.toStringAsFixed(2),
    );
  }

  @override
  void didUpdateWidget(PaymentEntryTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reflect amounts set elsewhere (e.g. the default payer seed) in the field,
    // but leave the field alone while the user is editing it themselves.
    final double current = double.tryParse(_amount.text) ?? 0;
    if (widget.amount != current) {
      _amount.text = widget.amount == 0 ? '' : widget.amount.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: widget.person.avatarColor,
            child: Text(
              _initial(widget.person.name),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(widget.person.name)),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: TextField(
              controller: _amount,
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                labelText: 'Paid',
                isDense: true,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              onChanged: (String value) =>
                  widget.onChanged(double.tryParse(value) ?? 0),
            ),
          ),
        ],
      ),
    );
  }

  String _initial(String name) =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}
