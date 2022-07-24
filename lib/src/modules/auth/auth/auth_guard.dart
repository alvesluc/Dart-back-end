import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import '../../../core/services/jwt/jwt_service.dart';
import '../../../core/services/request_extractor/request_extractor.dart';

class AuthGuard extends ModularMiddleware {
  final List<String> roles;
  final bool isRefreshToken;

  AuthGuard({this.roles = const [], this.isRefreshToken = false});

  @override
  Handler call(Handler handler, [ModularRoute? route]) {
    final extractor = Modular.get<RequestExtractor>();
    final jwt = Modular.get<JWTService>();

    return (request) {
      if (!request.headers.containsKey('authorization')) {
        return Response.forbidden(jsonEncode({
          'error': 'Header has no authorization token',
        }));
      }

      final token = extractor.getAuthorizationBearer(request);
      try {
        jwt.verifyToken(token, isRefreshToken ? 'refreshToken' : 'accessToken');
        final payload = jwt.getPayload(token);
        final role = payload['role'] ?? 'user';

        if (roles.isEmpty || roles.contains(role)) {
          return handler(request);
        }

        return Response.forbidden(jsonEncode({
          'error': 'Invalid role',
        }));
      } catch (e) {
        return Response.forbidden(jsonEncode({
          'error': e.toString(),
        }));
      }
    };
  }
}
