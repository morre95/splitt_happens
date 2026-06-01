import 'package:flutter/material.dart' hide Split;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../models/bill.dart';
import '../../providers/bill_provider.dart';
import 'assignment_tile.dart';

/// Assign each item to one or more people. Selecting multiple people splits
/// the item equally between them.
class AssignScreen extends ConsumerWidget {
  /// Creates an [AssignScreen].
  const AssignScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Bill? bill = ref.watch(billControllerProvider).valueOrNull;
    if (bill == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final BillController controller =
        ref.read(billControllerProvider.notifier);

    // Map of itemId -> set of assigned personIds, derived from splits.
    final Map<String, Set<String>> assigned = <String, Set<String>>{};
    for (final Split s in bill.splits) {
      assigned.putIfAbsent(s.itemId, () => <String>{}).add(s.personId);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign items'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.groups),
            tooltip: 'Split equally',
            onPressed: controller.splitEqually,
          ),
          TextButton(
            onPressed: () => context.push(Routes.summary),
            child: const Text('Summary'),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: bill.items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          final Item item = bill.items[index];
          return AssignmentTile(
            item: item,
            people: bill.people,
            assignedPersonIds:
                assigned[item.id] ?? const <String>{},
            currency: bill.currency,
            onToggle: (String personId, bool selected) =>
                controller.assignItem(item.id, personId, selected),
          );
        },
      ),
    );
  }
}
