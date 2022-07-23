import 'dart:convert';

import 'package:shelf/shelf.dart';

class RequestExtractor {
  String getAuthorizationBearer(Request request) {
    var authorization = request.headers['authorization'] ?? '';
    authorization = authorization.split(' ').last;
    
    return authorization;
  }

  LoginCredentials getAuthorizationBasic(Request request) {
    var authorization = request.headers['authorization'] ?? '';
    authorization = authorization.split(' ').last;
    authorization = String.fromCharCodes(base64Decode(authorization));
    final credentials = authorization.split(':');

    return LoginCredentials(
      email: credentials.first,
      password: credentials.last,
    );
  }
}

class LoginCredentials {
  final String email;
  final String password;

  LoginCredentials({required this.email, required this.password});
}
