import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../models/bill.dart';
import '../../providers/bill_provider.dart';
import '../../widgets/error_retry_view.dart';
import 'bill_card_widget.dart';

/// Landing screen: lists past bills and offers a FAB to start a new scan.
class HomeScreen extends ConsumerWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Bill>> bills = ref.watch(savedBillsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Happens'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: bills.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, _) => ErrorRetryView(
          error: error,
          onRetry: () => ref.invalidate(savedBillsProvider),
        ),
        data: (List<Bill> list) =>
            list.isEmpty ? const _EmptyState() : _BillList(bills: list),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(billControllerProvider.notifier).reset();
          context.push(Routes.scan);
        },
        icon: const Icon(Icons.camera_alt),
        label: const Text('New bill'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No bills yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text('Tap “New bill” to scan a receipt.'),
        ],
      ),
    );
  }
}

class _BillList extends ConsumerWidget {
  const _BillList({required this.bills});

  final List<Bill> bills;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: bills.length,
      itemBuilder: (BuildContext context, int index) {
        final Bill bill = bills[index];
        return BillCardWidget(
          bill: bill,
          onTap: () {
            ref.read(billControllerProvider.notifier).load(bill);
            context.push(Routes.summary);
          },
          onDelete: () async {
            await ref.read(billDaoProvider).deleteBill(bill.id);
            ref.invalidate(savedBillsProvider);
          },
        );
      },
    );
  }
}
