import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

void main(List<String> arguments) async {
  var pipeline = Pipeline().addMiddleware(log());

  final server = await io.serve(pipeline.addHandler(_handler), '0.0.0.0', 8080);

  print("[SERVER] Running on port ${server.port}");
}

Middleware log() {
  return (handler) {
    return (request) async {
      // Before execution:
      print('[REQUEST] ${request.url}');
      var response = await handler(request);

      // After execution:
      print('[RESPONSE] ${response.statusCode}');
      return response;
    };
  };
}

FutureOr<Response> _handler(Request request) {
  return Response(200, body: 'Body');
}
