/// Application-wide constants for Split Happens.
///
/// Centralises configuration that is referenced across multiple layers
/// (services, providers, screens) so there is a single source of truth.
library;

/// Networking and model configuration for the OpenRouter LLM parser.
class OpenRouterConfig {
  const OpenRouterConfig._();

  /// Base endpoint for chat completions.
  static const String chatCompletionsUrl =
      'https://openrouter.ai/api/v1/chat/completions';

  /// Default model used to parse receipts. Cheap and fast.
  static const String defaultModel = 'google/gemini-2.5-flash-lite';

  /// Models offered in the settings dropdown.
  static const List<String> availableModels = <String>[
    'google/gemini-2.5-flash-lite',
    'openai/gpt-5.4-nano',
    'anthropic/claude-haiku-4-5',
  ];

  /// Value sent as the `HTTP-Referer` header, identifying this app to
  /// OpenRouter for usage attribution.
  static const String httpReferer = 'Split Happens.app';

  /// Hard timeout applied to the OpenRouter HTTP call.
  static const Duration requestTimeout = Duration(seconds: 15);

  /// Low temperature for deterministic extraction.
  static const double temperature = 0.1;
}

/// Keys used to persist settings. The API key is stored in secure storage;
/// the model and currency live in `SharedPreferences`.
class SettingsKeys {
  const SettingsKeys._();

  static const String apiKey = 'openrouter_api_key';
  static const String model = 'preferred_model';
  static const String currency = 'currency';
}

/// Default values for user-configurable settings.
class SettingsDefaults {
  const SettingsDefaults._();

  static const String model = OpenRouterConfig.defaultModel;
  static const String currency = 'USD';
}
