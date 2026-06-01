import 'package:drift/drift.dart';

import '../app_database.dart';

part 'person_dao.g.dart';

/// Data-access object for person-level queries that span bills, such as
/// suggesting names the user has entered before.
@DriftAccessor(tables: <Type>[People])
class PersonDao extends DatabaseAccessor<AppDatabase> with _$PersonDaoMixin {
  /// Creates a [PersonDao] bound to [db].
  PersonDao(super.db);

  /// Returns the distinct set of person names previously used, ordered
  /// alphabetically — useful for autocomplete when adding people.
  Future<List<String>> distinctNames() async {
    final List<PersonRow> rows = await (select(people)
          ..orderBy(<OrderingTerm Function($PeopleTable)>[
            (People t) => OrderingTerm.asc(t.name),
          ]))
        .get();
    return rows.map((PersonRow r) => r.name).toSet().toList();
  }
}
