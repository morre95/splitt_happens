// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ocrServiceHash() => r'a82851570e4eb687efe5c163e55caa59763acfe4';

/// Provides the shared [OcrService] instance.
///
/// Copied from [ocrService].
@ProviderFor(ocrService)
final ocrServiceProvider = Provider<OcrService>.internal(
  ocrService,
  name: r'ocrServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ocrServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OcrServiceRef = ProviderRef<OcrService>;
String _$imagePreprocessorHash() => r'c57c68eac2290ce4e530f8671123e8f6eb7d5ac8';

/// Provides the shared [ImagePreprocessor] instance.
///
/// Copied from [imagePreprocessor].
@ProviderFor(imagePreprocessor)
final imagePreprocessorProvider = Provider<ImagePreprocessor>.internal(
  imagePreprocessor,
  name: r'imagePreprocessorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$imagePreprocessorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ImagePreprocessorRef = ProviderRef<ImagePreprocessor>;
String _$ocrTextHash() => r'69bceaf008d1ac1566b2be9d5a68cf8938fb4b9b';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Pre-processes [image] and runs on-device OCR, returning the recognised
/// text. Errors surface as [OcrException](../core/exceptions.dart) through the
/// resulting [AsyncValue].
///
/// Copied from [ocrText].
@ProviderFor(ocrText)
const ocrTextProvider = OcrTextFamily();

/// Pre-processes [image] and runs on-device OCR, returning the recognised
/// text. Errors surface as [OcrException](../core/exceptions.dart) through the
/// resulting [AsyncValue].
///
/// Copied from [ocrText].
class OcrTextFamily extends Family<AsyncValue<String>> {
  /// Pre-processes [image] and runs on-device OCR, returning the recognised
  /// text. Errors surface as [OcrException](../core/exceptions.dart) through the
  /// resulting [AsyncValue].
  ///
  /// Copied from [ocrText].
  const OcrTextFamily();

  /// Pre-processes [image] and runs on-device OCR, returning the recognised
  /// text. Errors surface as [OcrException](../core/exceptions.dart) through the
  /// resulting [AsyncValue].
  ///
  /// Copied from [ocrText].
  OcrTextProvider call(File image) {
    return OcrTextProvider(image);
  }

  @override
  OcrTextProvider getProviderOverride(covariant OcrTextProvider provider) {
    return call(provider.image);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'ocrTextProvider';
}

/// Pre-processes [image] and runs on-device OCR, returning the recognised
/// text. Errors surface as [OcrException](../core/exceptions.dart) through the
/// resulting [AsyncValue].
///
/// Copied from [ocrText].
class OcrTextProvider extends AutoDisposeFutureProvider<String> {
  /// Pre-processes [image] and runs on-device OCR, returning the recognised
  /// text. Errors surface as [OcrException](../core/exceptions.dart) through the
  /// resulting [AsyncValue].
  ///
  /// Copied from [ocrText].
  OcrTextProvider(File image)
    : this._internal(
        (ref) => ocrText(ref as OcrTextRef, image),
        from: ocrTextProvider,
        name: r'ocrTextProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$ocrTextHash,
        dependencies: OcrTextFamily._dependencies,
        allTransitiveDependencies: OcrTextFamily._allTransitiveDependencies,
        image: image,
      );

  OcrTextProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.image,
  }) : super.internal();

  final File image;

  @override
  Override overrideWith(FutureOr<String> Function(OcrTextRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: OcrTextProvider._internal(
        (ref) => create(ref as OcrTextRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        image: image,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _OcrTextProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OcrTextProvider && other.image == image;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, image.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OcrTextRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `image` of this provider.
  File get image;
}

class _OcrTextProviderElement extends AutoDisposeFutureProviderElement<String>
    with OcrTextRef {
  _OcrTextProviderElement(super.provider);

  @override
  File get image => (origin as OcrTextProvider).image;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
