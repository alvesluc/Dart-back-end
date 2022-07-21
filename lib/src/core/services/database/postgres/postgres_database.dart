import 'dart:async';

import 'package:postgres/postgres.dart';
import 'package:shelf_modular/shelf_modular.dart';

import '../../dot_env/dot_env_service.dart';
import '../remote_database.dart';

class PostgresDatabase implements RemoteDatabase, Disposable {
  final completer = Completer<PostgreSQLConnection>();
  final DotEnvService dotEnv;

  PostgresDatabase(this.dotEnv) {
    _init();
  }

  _init() async {
    final url = dotEnv['DATABASE_URL']!;
    final uri = Uri.parse(url);

    final database = uri.pathSegments.first;
    final username = uri.userInfo.split(':').first;
    final password = uri.userInfo.split(':').last;

    var connection = PostgreSQLConnection(
      uri.host,
      uri.port,
      database,
      username: username,
      password: password,
    );
    await connection.open();
    completer.complete(connection);
  }

  @override
  Future<List<Map<String, Map<String, dynamic>>>> query(
    String queryText, {
    Map<String, String> variables = const {},
  }) async {
    final connection = await completer.future;

    return connection.mappedResultsQuery(
      queryText,
      substitutionValues: variables,
    );
  }

  @override
  void dispose() async {
    final connection = await completer.future;
    connection.close();
  }
}
