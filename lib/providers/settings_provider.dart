import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

part 'settings_provider.g.dart';

/// User-configurable settings: the OpenRouter API key, preferred model, and
/// display currency.
class AppSettings {
  /// Creates an immutable [AppSettings].
  const AppSettings({
    required this.apiKey,
    required this.model,
    required this.currency,
  });

  /// OpenRouter API key. Empty when not yet configured.
  final String apiKey;

  /// Preferred OpenRouter model id.
  final String model;

  /// ISO currency code used to format amounts.
  final String currency;

  /// Whether the user has supplied an API key.
  bool get hasApiKey => apiKey.trim().isNotEmpty;

  /// Returns a copy with the given fields replaced.
  AppSettings copyWith({String? apiKey, String? model, String? currency}) {
    return AppSettings(
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      currency: currency ?? this.currency,
    );
  }
}

/// Loads and persists [AppSettings]. The OpenRouter API key is kept in
/// platform-encrypted secure storage (Keychain / KeyStore via RSA OAEP +
/// AES-GCM); the non-sensitive model and currency preferences live in
/// `SharedPreferences`.
@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  Future<AppSettings> build() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String apiKey =
        await _secureStorage.read(key: SettingsKeys.apiKey) ?? '';
    return AppSettings(
      apiKey: apiKey,
      model: _resolveModel(prefs.getString(SettingsKeys.model)),
      currency:
          prefs.getString(SettingsKeys.currency) ?? SettingsDefaults.currency,
    );
  }

  /// Returns [stored] only if it is still a known model; otherwise falls back
  /// to the default. This keeps the settings dropdown valid when a previously
  /// saved model id is renamed or removed from [OpenRouterConfig.availableModels].
  String _resolveModel(String? stored) {
    return OpenRouterConfig.availableModels.contains(stored)
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

  /// Securely persists the OpenRouter [apiKey]. An empty value clears it.
  Future<void> setApiKey(String apiKey) async {
    if (apiKey.isEmpty) {
      await _secureStorage.delete(key: SettingsKeys.apiKey);
    } else {
      await _secureStorage.write(key: SettingsKeys.apiKey, value: apiKey);
    }
    await _applyToState((AppSettings s) => s.copyWith(apiKey: apiKey));
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
