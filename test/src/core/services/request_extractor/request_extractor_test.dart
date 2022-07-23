import 'dart:convert';

import 'package:backend/src/core/services/request_extractor/request_extractor.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  final extractor = RequestExtractor();

  group('RequestExtractor', () {
    test('getAuthorizationBearer', () async {
      final request = Request('GET', Uri.parse('http://localhost/'), headers: {
        'authorization': 'Bearer token',
      });

      final token = extractor.getAuthorizationBearer(request);
      expect(token, 'token');
    });

    test('getAuthorizationBasic', () async {
      var authCredential = 'lucas@vsdi.com.br:12345678';
      authCredential = base64Encode(authCredential.codeUnits);
  
      final request = Request('GET', Uri.parse('http://localhost/'), headers: {
        'authorization': 'Basic $authCredential',
      });

      final token = extractor.getAuthorizationBasic(request);
      expect(token.email, 'lucas@vsdi.com.br');
      expect(token.password, '12345678');
    });
  });
}
