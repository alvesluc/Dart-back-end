import 'package:backend/src/core/services/dot_env/dot_env_service.dart';
import 'package:backend/src/core/services/jwt/dart_jsonwebtoken/jwt_service_imp.dart';
import 'package:test/test.dart';

void main() {
  group('JWT', () {
    test('create token', () async {
      final dotEnvService = DotEnvService(
        mocks: {'JWT_KEY': 'g&DT%32l4jg'},
      );
      final jwt = JWTServiceImp(dotEnvService);

      final expiresDate = DateTime.now().add(Duration(seconds: 30));
      final expiresIn = Duration(
        milliseconds: expiresDate.millisecondsSinceEpoch,
      ).inSeconds;

      final token = jwt.generateToken({
        'id': 1,
        'role': 'user',
        'exp': expiresIn,
      }, 'accessToken');

      print(token);
    });

    test('verify token', () async {
      final dotEnvService = DotEnvService(
        mocks: {'JWT_KEY': 'g&DT%32l4jg'},
      );
      final jwt = JWTServiceImp(dotEnvService);

      jwt.verifyToken(
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwicm9sZSI6InVzZXIiLCJleHAiOjE2NTg0NTM4NTAsImlhdCI6MTY1ODQ1MzgyMCwiYXVkIjoiYWNjZXNzVG9rZW4ifQ.6ED_2nBzgDMBpkYo6vG78BNRaPsdLeBVKq4hfgIW8z4',
        'accessToken',
      );
    });

    test('jwt payload', () async {
      final dotEnvService = DotEnvService(
        mocks: {'JWT_KEY': 'g&DT%32l4jg'},
      );
      final jwt = JWTServiceImp(dotEnvService);

      final payload = jwt.getPayload(
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwicm9sZSI6InVzZXIiLCJleHAiOjE2NTg0NTM4NTAsImlhdCI6MTY1ODQ1MzgyMCwiYXVkIjoiYWNjZXNzVG9rZW4ifQ.6ED_2nBzgDMBpkYo6vG78BNRaPsdLeBVKq4hfgIW8z4',
      );

      print(payload);
    });
  });
}
