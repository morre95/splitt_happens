/// Application-wide constants for Split Happens.
///
/// Centralises configuration that is referenced across multiple layers
/// (services, providers, screens) so there is a single source of truth.
library;

/// Networking and model configuration for the Split Happens backend.
///
/// The app talks to its own backend, which proxies LLM requests through
/// LiteLLM (enforcing a per-user budget) and registers each device. The
/// backend host is supplied at build time:
/// `flutter run --dart-define=BACKEND_BASE_URL=http://my-host:8000`.
class BackendConfig {
  const BackendConfig._();

  /// Base URL of the backend. Defaults to the Android-emulator loopback host
  /// (`10.0.2.2` maps to the host machine's `localhost`); override per platform
  /// with `--dart-define=BACKEND_BASE_URL=...`.
  static const String baseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// OpenAI-compatible chat-completions endpoint exposed by the backend proxy.
  static const String chatCompletionsPath = '/v1/chat/completions';

  /// Device registration / token-refresh endpoint.
  static const String registerPath = '/auth/register';

  /// Default model used to parse receipts. Cheap and fast.
  static const String defaultModel = 'google/gemini-2.5-flash-lite';

  /// Models offered in the settings dropdown. These match the aliases the
  /// backend's LiteLLM config exposes.
  static const List<String> availableModels = <String>[
    'google/gemini-2.5-flash-lite',
    'openai/gpt-5.4-nano',
    'anthropic/claude-haiku-4-5',
  ];

  /// Hard timeout applied to backend HTTP calls.
  static const Duration requestTimeout = Duration(seconds: 15);

  /// Low temperature for deterministic extraction.
  static const double temperature = 0.1;
}

/// Keys used to persist settings and identity.
///
/// The device id and app token are stored in secure storage; the model and
/// currency preferences live in `SharedPreferences`.
class SettingsKeys {
  const SettingsKeys._();

  static const String model = 'preferred_model';
  static const String currency = 'currency';

  /// Stable per-install device identifier (secure storage).
  static const String deviceId = 'device_id';

  /// Opaque backend app token (secure storage); rotates on refresh.
  static const String appToken = 'app_token';
}

/// Default values for user-configurable settings.
class SettingsDefaults {
  const SettingsDefaults._();

  static const String model = BackendConfig.defaultModel;
  static const String currency = 'USD';
}
