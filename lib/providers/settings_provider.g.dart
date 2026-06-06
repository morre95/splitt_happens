// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsHash() => r'72243293546f5f78b729cedbda98820ad79d28a8';

/// Loads and persists [AppSettings]. Both the model and currency preferences
/// are non-sensitive and live in `SharedPreferences`.
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
