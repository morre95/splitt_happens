import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/error_retry_view.dart';

/// Lets the user enter their OpenRouter API key and pick a parsing model.
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

class _SettingsForm extends ConsumerStatefulWidget {
  const _SettingsForm({required this.settings});

  final AppSettings settings;

  @override
  ConsumerState<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<_SettingsForm> {
  late final TextEditingController _apiKey;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _apiKey = TextEditingController(text: widget.settings.apiKey);
  }

  @override
  void dispose() {
    _apiKey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Settings notifier = ref.read(settingsProvider.notifier);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          'OpenRouter API key',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _apiKey,
          obscureText: _obscure,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'sk-or-...',
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          onChanged: notifier.setApiKey,
        ),
        const SizedBox(height: 24),
        Text(
          'Parsing model',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: widget.settings.model,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: OpenRouterConfig.availableModels
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
