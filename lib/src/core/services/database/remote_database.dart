abstract class RemoteDatabase {
  Future<List<Map<String, Map<String, dynamic>>>> query(
    String queryText, {
    Map<String, String> variables = const {},
  });
}
