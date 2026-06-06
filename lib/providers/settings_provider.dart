import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

part 'settings_provider.g.dart';

/// User-configurable settings: the preferred parsing model and display
/// currency. Authentication is handled by the backend device token, not here.
class AppSettings {
  /// Creates an immutable [AppSettings].
  const AppSettings({
    required this.model,
    required this.currency,
  });

  /// Preferred model id (forwarded to the backend proxy).
  final String model;

  /// ISO currency code used to format amounts.
  final String currency;

  /// Returns a copy with the given fields replaced.
  AppSettings copyWith({String? model, String? currency}) {
    return AppSettings(
      model: model ?? this.model,
      currency: currency ?? this.currency,
    );
  }
}

/// Loads and persists [AppSettings]. Both the model and currency preferences
/// are non-sensitive and live in `SharedPreferences`.
@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  @override
  Future<AppSettings> build() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return AppSettings(
      model: _resolveModel(prefs.getString(SettingsKeys.model)),
      currency:
          prefs.getString(SettingsKeys.currency) ?? SettingsDefaults.currency,
    );
  }

  /// Returns [stored] only if it is still a known model; otherwise falls back
  /// to the default. This keeps the settings dropdown valid when a previously
  /// saved model id is renamed or removed from [BackendConfig.availableModels].
  String _resolveModel(String? stored) {
    return BackendConfig.availableModels.contains(stored)
        ? stored!
        : SettingsDefaults.model;
  }

  /// Updates [state] by applying [apply] to the current settings.
  Future<void> _applyToState(AppSettings Function(AppSettings) apply) async {
    final AppSettings current = state.valueOrNull ?? await future;
    state = AsyncData<AppSettings>(apply(current));
  }

  /// Persists a non-sensitive [value] under [key] in `SharedPreferences`.
  Future<void> _setPref(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  /// Persists the preferred [model].
  Future<void> setModel(String model) async {
    await _setPref(SettingsKeys.model, model);
    await _applyToState((AppSettings s) => s.copyWith(model: model));
  }

  /// Persists the display [currency].
  Future<void> setCurrency(String currency) async {
    await _setPref(SettingsKeys.currency, currency);
    await _applyToState((AppSettings s) => s.copyWith(currency: currency));
  }
}
