import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AuthResource extends Resource {
  @override
  List<Route> get routes => [
        Route.get('/auth/login', _login),
        Route.get('/auth/refresh_token', _refreshToken),
        Route.get('/auth/check_token', _checkToken),
        Route.get('/auth/update_password', _checkToken),
      ];

  FutureOr<Response> _login() {
    return Response.ok('body');
  }

  FutureOr<Response> _refreshToken() {
    return Response.ok('body');
  }

  FutureOr<Response> _checkToken() {
    return Response.ok('body');
  }

  FutureOr<Response> _updatePassword() {
    return Response.ok('body');
  }
}
