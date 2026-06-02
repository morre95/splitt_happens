// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'8c7fb583737b35e44dd8ca0588453404ef77bcc3';

/// Provides the singleton [AppDatabase].
///
/// Copied from [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = Provider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = ProviderRef<AppDatabase>;
String _$billDaoHash() => r'2b1f47968c52a7362e2d36994da1789397e0cd1d';

/// Provides the [BillDao].
///
/// Copied from [billDao].
@ProviderFor(billDao)
final billDaoProvider = Provider<BillDao>.internal(
  billDao,
  name: r'billDaoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$billDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BillDaoRef = ProviderRef<BillDao>;
String _$savedBillsHash() => r'62b2ef3b9a70e201ca5672edba961290df2711b9';

/// Streams the list of saved bills, most recent first.
///
/// Copied from [savedBills].
@ProviderFor(savedBills)
final savedBillsProvider = AutoDisposeFutureProvider<List<Bill>>.internal(
  savedBills,
  name: r'savedBillsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$savedBillsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SavedBillsRef = AutoDisposeFutureProviderRef<List<Bill>>;
String _$billControllerHash() => r'75d4c2aa4c390d98df46f5eae326e852644287f3';

/// Drives a single receipt-splitting session through its lifecycle:
/// `idle → scanning → reviewing → assigning → summarised`.
///
/// Stages map onto the exposed [currentBill]:
/// * **scanning** — `AsyncLoading` while OCR + LLM parsing run;
/// * **reviewing / assigning / summarised** — `AsyncData`, distinguished by
///   the active route;
/// * pipeline failures surface as `AsyncError`.
///
/// Copied from [BillController].
@ProviderFor(BillController)
final billControllerProvider =
    AutoDisposeAsyncNotifierProvider<BillController, Bill>.internal(
      BillController.new,
      name: r'billControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$billControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BillController = AutoDisposeAsyncNotifier<Bill>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
