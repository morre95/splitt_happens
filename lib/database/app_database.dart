import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/bill_dao.dart';
import 'daos/person_dao.dart';

part 'app_database.g.dart';

/// Top-level container persisted to SQLite.
@DataClassName('BillRow')
class Bills extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// User-facing bill name.
  TextColumn get name => text()();

  /// When the bill was created.
  DateTimeColumn get date => dateTime()();

  /// Total tax charged.
  RealColumn get taxAmount => real().withDefault(const Constant(0))();

  /// Total tip added.
  RealColumn get tipAmount => real().withDefault(const Constant(0))();

  /// ISO currency code.
  TextColumn get currency => text().withDefault(const Constant('USD'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// A receipt line item belonging to a bill.
@DataClassName('ItemRow')
class Items extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// Owning bill id.
  TextColumn get billId => text().references(Bills, #id)();

  /// Item name.
  TextColumn get name => text()();

  /// Quantity purchased.
  RealColumn get quantity => real()();

  /// Unit price.
  RealColumn get unitPrice => real()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// A participant in a bill.
@DataClassName('PersonRow')
class People extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// Owning bill id.
  TextColumn get billId => text().references(Bills, #id)();

  /// Display name.
  TextColumn get name => text()();

  /// Avatar colour as a 32-bit ARGB integer.
  IntColumn get avatarColor => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// An item-to-person ownership fraction.
@DataClassName('SplitRow')
class Splits extends Table {
  /// Synthetic UUID primary key.
  TextColumn get id => text()();

  /// Owning bill id.
  TextColumn get billId => text()();

  /// The split item id.
  TextColumn get itemId => text()();

  /// The owning person id.
  TextColumn get personId => text()();

  /// Numerator of the owned portion.
  IntColumn get portionNumerator => integer()();

  /// Denominator of the owned portion.
  IntColumn get portionDenominator => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// How much a person paid towards a bill.
@DataClassName('PaymentRow')
class Payments extends Table {
  /// Synthetic UUID primary key (`'{billId}:{personId}'`).
  TextColumn get id => text()();

  /// Owning bill id.
  TextColumn get billId => text()();

  /// The paying person id.
  TextColumn get personId => text()();

  /// Amount paid, in currency units.
  RealColumn get amount => real()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// The application's Drift/SQLite database.
@DriftDatabase(
  tables: <Type>[Bills, Items, People, Splits, Payments],
  daos: <Type>[BillDao, PersonDao],
)
class AppDatabase extends _$AppDatabase {
  /// Opens the database, optionally with an injected [executor] (used in
  /// tests).
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) async {
          // v2 adds the Payments table for settle-up tracking.
          if (from < 2) {
            await m.createTable(payments);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final Directory dir = await getApplicationDocumentsDirectory();
      final File file = File(p.join(dir.path, 'split_happens.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
