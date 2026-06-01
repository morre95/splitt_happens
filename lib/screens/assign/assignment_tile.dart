import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../models/bill.dart';

/// A row for one [Item] showing its price and a togglable avatar per person.
/// Selected avatars share the item; a fraction badge shows each sharer's
/// portion when more than one person is selected.
class AssignmentTile extends StatelessWidget {
  /// Creates an [AssignmentTile].
  const AssignmentTile({
    required this.item,
    required this.people,
    required this.assignedPersonIds,
    required this.currency,
    required this.onToggle,
    super.key,
  });

  /// The item being assigned.
  final Item item;

  /// Everyone available to assign.
  final List<Person> people;

  /// Ids of people currently sharing this item.
  final Set<String> assignedPersonIds;

  /// Currency code for price formatting.
  final String currency;

  /// Called when a person's avatar is toggled.
  final void Function(String personId, bool selected) onToggle;

  @override
  Widget build(BuildContext context) {
    final int sharers = assignedPersonIds.length;
    final String? fraction = sharers > 1 ? '1/$sharers' : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(formatMoney(item.lineTotal, currency)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: people.map((Person person) {
              final bool selected = assignedPersonIds.contains(person.id);
              return _AvatarToggle(
                person: person,
                selected: selected,
                badge: selected ? fraction : null,
                onTap: () => onToggle(person.id, !selected),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AvatarToggle extends StatelessWidget {
  const _AvatarToggle({
    required this.person,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final Person person;
  final bool selected;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          AnimatedOpacity(
            opacity: selected ? 1 : 0.35,
            duration: const Duration(milliseconds: 150),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: person.avatarColor,
                child: Text(
                  _initial(person.name),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          if (badge != null)
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _initial(String name) =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}
