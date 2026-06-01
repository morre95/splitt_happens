import 'package:flutter/material.dart';

import '../../models/bill.dart';

/// A chip displaying a [Person]'s coloured avatar and name, with an optional
/// delete affordance.
class PersonChip extends StatelessWidget {
  /// Creates a [PersonChip].
  const PersonChip({required this.person, this.onDeleted, super.key});

  /// The person to display.
  final Person person;

  /// Called when the chip's delete icon is tapped. When null, no delete icon
  /// is shown.
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: person.avatarColor,
        child: Text(
          _initial(person.name),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      label: Text(person.name),
      onDeleted: onDeleted,
    );
  }

  String _initial(String name) =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}
