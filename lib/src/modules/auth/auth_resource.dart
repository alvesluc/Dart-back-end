import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import '../../core/services/bcrypt/bcrypt_service.dart';
import '../../core/services/database/remote_database.dart';
import '../../core/services/jwt/jwt_service.dart';
import '../../core/services/request_extractor/request_extractor.dart';
import '../../utils/to_query_extension.dart';
import 'auth/auth_guard.dart';

class AuthResource extends Resource {
  @override
  List<Route> get routes => [
        Route.get('/auth/login', _login),
        Route.get('/auth/refresh_token', _refreshToken, middlewares: [
          AuthGuard(isRefreshToken: true),
        ]),
        Route.get('/auth/check_token', _checkToken, middlewares: [
          AuthGuard(),
        ]),
        Route.put('/auth/update_password', _updatePassword, middlewares: [
          AuthGuard(),
        ]),
      ];

  FutureOr<Response> _login(Request request, Injector injector) async {
    final extractor = injector.get<RequestExtractor>();
    final bcrypt = injector.get<BCryptService>();
    final jwt = injector.get<JWTService>();
    final credentials = extractor.getAuthorizationBasic(request);
    final database = injector.get<RemoteDatabase>();

    final result = await database.query(
      '''
      SELECT id, role, password
      FROM "User" WHERE email = @email;
      '''
          .toQuery(),
      variables: {'email': credentials.email},
    );

    if (result.isEmpty) {
      return Response.forbidden(jsonEncode(
        {'error': 'Invalid email or password'},
      ));
    }

    final userMap = result.map((e) => e['User']).first!;

    if (!bcrypt.checkHash(credentials.password, userMap['password'])) {
      return Response.forbidden(jsonEncode(
        {'error': 'Invalid email or password'},
      ));
    }

    final payload = userMap..remove('password');

    return Response.ok(jsonEncode(_generateToken(payload, jwt)));
  }

  Map _generateToken(Map payload, JWTService jwt) {
    payload['exp'] = _determineExpiration(Duration(minutes: 10));
    final accessToken = jwt.generateToken(payload, 'accessToken');

    payload['exp'] = _determineExpiration(Duration(days: 3));
    final refreshToken = jwt.generateToken(payload, 'refreshToken');

    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  FutureOr<Response> _refreshToken(Request request, Injector injector) async {
    final extractor = injector.get<RequestExtractor>();
    final jwt = injector.get<JWTService>();
    final database = injector.get<RemoteDatabase>();

    final token = extractor.getAuthorizationBearer(request);
    var payload = jwt.getPayload(token);

    final result = await database.query(
      '''
      SELECT id, role
      FROM "User" WHERE id = @id;
      '''
          .toQuery(),
      variables: {'id': payload['id']},
    );

    payload = result.map((e) => e['User']).first!;
    _generateToken(payload, jwt);

    return Response.ok(jsonEncode(_generateToken(payload, jwt)));
  }

  FutureOr<Response> _checkToken() async {
    return Response.ok(jsonEncode({'message': true}));
  }

  FutureOr<Response> _updatePassword(
    Request request,
    Injector injector,
    ModularArguments arguments,
  ) async {
    final extractor = injector.get<RequestExtractor>();
    final bcrypt = injector.get<BCryptService>();
    final jwt = injector.get<JWTService>();
    final database = injector.get<RemoteDatabase>();
    final data = arguments.data as Map;

    final token = extractor.getAuthorizationBearer(request);
    var payload = jwt.getPayload(token);

    final result = await database.query(
      '''
      SELECT password
      FROM "User" WHERE id = @id;
      '''
          .toQuery(),
      variables: {'id': payload['id']},
    );

    final password = result.map((e) => e['User']).first!['password'];

    if (!bcrypt.checkHash(data['password'], password)) {
      return Response.forbidden(jsonEncode(
        {'error': 'Invalid password'},
      ));
    }

    await database.query(
      '''
      UPDATE "User" SET password=@password
      WHERE id = @id;
      '''
          .toQuery(),
      variables: {
        'id': payload['id'],
        'password': bcrypt.generateHash(data['newPassword']),
      },
    );

    return Response.ok(jsonEncode({'message': 'Password updated'}));
  }

  int _determineExpiration(Duration duration) {
    final expiresDate = DateTime.now().add(duration);
    final expiresIn = Duration(
      milliseconds: expiresDate.millisecondsSinceEpoch,
    );

    return expiresIn.inSeconds;
  }
}
