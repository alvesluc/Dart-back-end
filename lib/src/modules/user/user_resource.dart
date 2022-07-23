import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import '../../core/services/bcrypt/bcrypt_service.dart';
import '../../core/services/database/remote_database.dart';
import '../../utils/to_query_extension.dart';
import '../auth/auth/auth_guard.dart';

class UserResource extends Resource {
  @override
  List<Route> get routes => [
        Route.get('/user', _getAllUsers, middlewares: [AuthGuard()]),
        Route.get('/user/:id', _getUserById, middlewares: [AuthGuard()]),
        Route.post('/user', _createUser),
        Route.put('/user', _updateUser, middlewares: [AuthGuard()]),
        Route.delete('/user/:id', _deleteUser, middlewares: [
          AuthGuard(roles: ['ADMIN']),
        ]),
      ];

  FutureOr<Response> _getAllUsers(Injector injector) async {
    final database = injector.get<RemoteDatabase>();
    final result = await database.query(
      '''
      SELECT id, name, email, role
      FROM "User";
      '''
          .toQuery(),
    );
    final userList = result.map((e) => e['User']).toList();
    return Response.ok(jsonEncode(userList));
  }

  FutureOr<Response> _getUserById(
    ModularArguments arguments,
    Injector injector,
  ) async {
    final id = arguments.params['id'];
    final database = injector.get<RemoteDatabase>();
    final result = await database.query(
      '''
      SELECT id, name, email, role
      FROM "User" WHERE id = @id;
      '''
          .toQuery(),
      variables: {'id': id},
    );
    final userMap = result.map((element) => element['User']).first;
    return Response.ok(jsonEncode(userMap));
  }

  FutureOr<Response> _createUser(
    ModularArguments arguments,
    Injector injector,
  ) async {
    final userData = arguments.data as Map<String, dynamic>;

    final bcrypt = injector.get<BCryptService>();
    userData['password'] = bcrypt.generateHash(userData['password']);

    userData.remove('id');
    final database = injector.get<RemoteDatabase>();
    final result = await database.query(
      '''
      INSERT INTO "User"(name, email, password)
      VALUES (@name, @email, @password)
      RETURNING id, name, email, role;
      '''
          .toQuery(),
      variables: userData,
    );
    final newUserMap = result.map((e) => e['User']).first;
    return Response.ok(jsonEncode(newUserMap));
  }

  FutureOr<Response> _updateUser(
    ModularArguments arguments,
    Injector injector,
  ) async {
    final userData = (arguments.data as Map).cast<String, dynamic>();
    final database = injector.get<RemoteDatabase>();

    final updatedColumns = userData.keys
        .where((key) => key != 'id')
        .where((key) => key != 'password')
        .map((key) => '$key=@$key')
        .toList();

    final result = await database.query(
      '''
      UPDATE "User" SET ${updatedColumns.join(', ')} 
      WHERE id = @id 
      RETURNING id, name, email, role;
      '''
          .toQuery(),
      variables: userData,
    );
    final newUserMap = result.map((e) => e['User']).first;
    return Response.ok(jsonEncode(newUserMap));
  }

  FutureOr<Response> _deleteUser(
    ModularArguments arguments,
    Injector injector,
  ) async {
    final id = arguments.params['id'];
    final database = injector.get<RemoteDatabase>();
    await database.query(
      '''
      DELETE FROM public."User"
      WHERE id = @id
      '''
          .toQuery(),
      variables: {'id': id},
    );
    return Response.ok('[DELETED] user: ${arguments.params['id']}');
  }
}
