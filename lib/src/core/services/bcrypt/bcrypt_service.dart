abstract class BCryptService {
  String generateHash(String text);
  bool checkHash(String password, String hash);
}