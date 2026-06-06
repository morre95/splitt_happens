import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/error_retry_view.dart';

/// Lets the user pick a parsing model and display currency.
///
/// Authentication is handled automatically by the backend in the testing
/// phase — the device registers itself on first use, so there is no API key to
/// enter here.
class SettingsScreen extends ConsumerWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppSettings> settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, _) => ErrorRetryView(
          error: error,
          onRetry: () => ref.invalidate(settingsProvider),
        ),
        data: (AppSettings data) => _SettingsForm(settings: data),
      ),
    );
  }
}

class _SettingsForm extends ConsumerWidget {
  const _SettingsForm({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Settings notifier = ref.read(settingsProvider.notifier);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          'Parsing model',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: settings.model,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: BackendConfig.availableModels
              .map((String model) => DropdownMenuItem<String>(
                    value: model,
                    child: Text(model),
                  ))
              .toList(),
          onChanged: (String? model) {
            if (model != null) notifier.setModel(model);
          },
        ),
      ],
    );
  }
}
