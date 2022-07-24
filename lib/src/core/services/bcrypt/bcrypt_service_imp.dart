import 'package:bcrypt/bcrypt.dart';

import 'bcrypt_service.dart';

class BCryptServiceImp implements BCryptService {
  @override
  String generateHash(String text) {
    final String hashed = BCrypt.hashpw(text, BCrypt.gensalt());
    return hashed;
  }

  @override
  bool checkHash(String password, String hash) {
    return BCrypt.checkpw(password, hash);
  }
}
