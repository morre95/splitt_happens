import 'package:flutter/material.dart';

/// A full-width amber banner with a warning icon, used to surface
/// non-blocking validation messages (e.g. totals that don't add up).
class WarningBanner extends StatelessWidget {
  /// Creates a [WarningBanner] displaying [text].
  const WarningBanner({required this.text, super.key});

  /// The message to display.
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
