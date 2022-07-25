import '../../../core/services/bcrypt/bcrypt_service.dart';
import '../../../core/services/jwt/jwt_service.dart';
import '../../../core/services/request_extractor/request_extractor.dart';
import '../errors/errors.dart';
import '../models/tokens.dart';

abstract class AuthDatasource {
  Future<Map> getIdRoleAndPasswordByEmail(String email);
  Future<String> getRoleById(id);
  Future<String> getPasswordHashById(id);
  Future<void> updatePasswordHashById(id, String newPassword);
}

class AuthRepository {
  final BCryptService bcrypt;
  final JWTService jwt;
  final AuthDatasource datasource;

  AuthRepository(this.datasource, this.bcrypt, this.jwt);

  Future<Tokens> login(LoginCredentials credentials) async {
    final userMap =
        await datasource.getIdRoleAndPasswordByEmail(credentials.email);

    if (userMap.isEmpty) {
      throw AuthException(403, 'Invalid email or password');
    }

    if (!bcrypt.checkHash(credentials.password, userMap['password'])) {
      throw AuthException(403, 'Invalid email or password');
    }

    final payload = userMap..remove('password');

    return _generateToken(payload);
  }

  Future<Tokens> refreshToken(String token) async {
    final payload = jwt.getPayload(token);
    final role = await datasource.getRoleById(payload['id']);
    return _generateToken({
      'id': payload['id'],
      'role': role,
    });
  }

  Tokens _generateToken(Map payload) {
    payload['exp'] = _determineExpiration(Duration(minutes: 10));
    final accessToken = jwt.generateToken(payload, 'accessToken');

    payload['exp'] = _determineExpiration(Duration(days: 3));
    final refreshToken = jwt.generateToken(payload, 'refreshToken');

    return Tokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  int _determineExpiration(Duration duration) {
    final expiresDate = DateTime.now().add(duration);
    final expiresIn = Duration(
      milliseconds: expiresDate.millisecondsSinceEpoch,
    );

    return expiresIn.inSeconds;
  }

  Future<void> updatePassword({
    required String token,
    required String password,
    required String newPassword,
  }) async {
    var payload = jwt.getPayload(token);
    final passwordHash = await datasource.getPasswordHashById(payload['id']);

    if (!bcrypt.checkHash(password, passwordHash)) {
      throw AuthException(403, 'Invalid password');
    }

    newPassword = bcrypt.generateHash(newPassword);
    await datasource.updatePasswordHashById(payload['id'], newPassword);
  }
}
