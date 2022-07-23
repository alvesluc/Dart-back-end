import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import '../../core/services/bcrypt/bcrypt_service.dart';
import '../../core/services/database/remote_database.dart';
import '../../core/services/jwt/jwt_service.dart';
import '../../core/services/request_extractor/request_extractor.dart';
import '../../utils/to_query_extension.dart';

class AuthResource extends Resource {
  @override
  List<Route> get routes => [
        Route.get('/auth/login', _login),
        Route.get('/auth/refresh_token', _refreshToken),
        Route.get('/auth/check_token', _checkToken),
        Route.get('/auth/update_password', _checkToken),
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

    final userMap = result.map((element) => element['User']).first!;

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

  FutureOr<Response> _refreshToken() {
    return Response.ok('body');
  }

  FutureOr<Response> _checkToken() {
    return Response.ok('body');
  }

  FutureOr<Response> _updatePassword() {
    return Response.ok('body');
  }

  int _determineExpiration(Duration duration) {
    final expiresDate = DateTime.now().add(duration);
    final expiresIn = Duration(
      milliseconds: expiresDate.millisecondsSinceEpoch,
    );

    return expiresIn.inSeconds;
  }
}
