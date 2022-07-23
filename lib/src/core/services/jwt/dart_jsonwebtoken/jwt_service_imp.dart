import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../../dot_env/dot_env_service.dart';
import '../jwt_service.dart';

class JWTServiceImp implements JWTService {
  final DotEnvService dotEnvService;

  JWTServiceImp(this.dotEnvService);

  @override
  String generateToken(Map claims, String audience) {
    final jwt = JWT(claims, audience: Audience.one(audience));
    final token = jwt.sign(SecretKey(dotEnvService['JWT_KEY']!));
    return token;
  }

  @override
  void verifyToken(String token, String audience) {
    JWT.verify(
      token,
      SecretKey(dotEnvService['JWT_KEY']!),
      audience: Audience.one(audience),
    );
  }

  @override
  Map getPayload(String token) {
    final jwt = JWT.verify(
      token,
      SecretKey(dotEnvService['JWT_KEY']!),
      checkExpiresIn: false,
      checkHeaderType: false,
      checkNotBefore: false,
    );

    return jwt.payload;
  }
}
