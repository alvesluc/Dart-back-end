import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import '../../../core/services/request_extractor/request_extractor.dart';
import '../errors/errors.dart';
import '../guard/auth_guard.dart';
import '../repositories/auth_repository.dart';

class AuthResource extends Resource {
  @override
  List<Route> get routes => [
        Route.get('/login', _login),
        Route.get('/refresh_token', _refreshToken, middlewares: [
          AuthGuard(isRefreshToken: true),
        ]),
        Route.get('/check_token', _checkToken, middlewares: [
          AuthGuard(),
        ]),
        Route.put('/update_password', _updatePassword, middlewares: [
          AuthGuard(),
        ]),
      ];

  FutureOr<Response> _login(Request request, Injector injector) async {
    final authRepository = injector.get<AuthRepository>();
    final extractor = injector.get<RequestExtractor>();
    final credentials = extractor.getAuthorizationBasic(request);

    try {
      final tokens = await authRepository.login(credentials);
      return Response.ok(tokens.toJson());
    } on AuthException catch (e) {
      return Response(e.statusCode, body: e.toJson());
    }
  }

  FutureOr<Response> _refreshToken(Request request, Injector injector) async {
    final authRepository = injector.get<AuthRepository>();
    final extractor = injector.get<RequestExtractor>();

    final token = extractor.getAuthorizationBearer(request);

    final tokens = await authRepository.refreshToken(token);
    return Response.ok(tokens.toJson());
  }

  FutureOr<Response> _checkToken() async {
    return Response.ok(jsonEncode({'message': true}));
  }

  FutureOr<Response> _updatePassword(
    Request request,
    Injector injector,
    ModularArguments arguments,
  ) async {
    final authRepository = injector.get<AuthRepository>();
    final extractor = injector.get<RequestExtractor>();
    final data = arguments.data as Map;
    final token = extractor.getAuthorizationBearer(request);

    try {
      await authRepository.updatePassword(
        token: token,
        password: data['password'],
        newPassword: data['newPassword'],
      );
    } on AuthException catch (e) {
      return Response(e.statusCode, body: e.toJson());
    }

    return Response.ok(jsonEncode({'message': 'Password updated'}));
  }
}
