// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsHash() => r'1018dac3e7c7f76b1fc7e6e1d1da449a439a6453';

/// Loads and persists [AppSettings]. The OpenRouter API key is kept in
/// platform-encrypted secure storage (Keychain / KeyStore via RSA OAEP +
/// AES-GCM); the non-sensitive model and currency preferences live in
/// `SharedPreferences`.
///
/// Copied from [Settings].
@ProviderFor(Settings)
final settingsProvider = AsyncNotifierProvider<Settings, AppSettings>.internal(
  Settings.new,
  name: r'settingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Settings = AsyncNotifier<AppSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
