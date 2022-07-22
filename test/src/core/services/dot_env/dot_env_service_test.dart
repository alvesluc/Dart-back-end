import 'package:backend/src/core/services/dot_env/dot_env_service.dart';
import 'package:test/test.dart';

void main() {
  group('DotEnvService', () {
    test('can read .env', () async {
      final service = DotEnvService(mocks: {
        'DATABASE_URL': 'postgres://postgres:postgrespw@localhost:49153',
      });
      expect(service['DATABASE_URL'],
          'postgres://postgres:postgrespw@localhost:49153');
    });
  });
}
