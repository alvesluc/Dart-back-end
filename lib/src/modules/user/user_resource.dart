import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class UserResource extends Resource {
  @override
  List<Route> get routes => [
        Route.get('/user', _getAllUsers),
        Route.get('/user/:id', _getUserById),
        Route.post('/user', _createUser),
        Route.put('/user', _updateUser),
        Route.delete('/user/:id', _deleteUser)
      ];

  FutureOr<Response> _getAllUsers() {
    return Response.ok('[GET] users');
  }

  FutureOr<Response> _getUserById(ModularArguments arguments) {
    return Response.ok('[GET] user: ${arguments.params['id']}');
  }

  FutureOr<Response> _createUser(ModularArguments arguments) {
    return Response.ok('[POST] user: ${arguments.data}');
  }

  FutureOr<Response> _updateUser(ModularArguments arguments) {
    return Response.ok('[PUT] user: ${arguments.data}');
  }

  FutureOr<Response> _deleteUser(ModularArguments arguments) {
    return Response.ok('[DELETE] user: ${arguments.params['id']}');
  }
}
