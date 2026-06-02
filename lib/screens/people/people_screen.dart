import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../models/bill.dart';
import '../../providers/bill_provider.dart';
import 'person_chip.dart';

/// Add or remove the people sharing this bill before assigning items.
class PeopleScreen extends ConsumerStatefulWidget {
  /// Creates a [PeopleScreen].
  const PeopleScreen({super.key});

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  final TextEditingController _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _addPerson() {
    final String name = _name.text.trim();
    if (name.isEmpty) return;
    ref.read(billControllerProvider.notifier).addPerson(name);
    _name.clear();
  }

  @override
  Widget build(BuildContext context) {
    final Bill? bill = ref.watch(billControllerProvider).valueOrNull;
    if (bill == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final BillController controller =
        ref.read(billControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Who is splitting?'),
        actions: <Widget>[
          TextButton(
            onPressed: bill.people.isEmpty
                ? null
                : () => context.push(Routes.payments),
            child: const Text('Next'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _name,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Add a person',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addPerson(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _addPerson,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: bill.people.isEmpty
                  ? const Center(child: Text('Add at least one person.'))
                  : SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: bill.people
                            .map((Person p) => PersonChip(
                                  person: p,
                                  onDeleted: () =>
                                      controller.removePerson(p.id),
                                ))
                            .toList(),
                      ),
                    ),
            ),
            if (bill.people.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push(Routes.assign),
                  icon: const Icon(Icons.tune),
                  label: const Text('Assign items individually'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
