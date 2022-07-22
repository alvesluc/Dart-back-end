abstract class JWTService {
  String generateToken(Map claims, String audience);
  void verifyToken(String token, String audience);
  Map getPayload(String token);
}
