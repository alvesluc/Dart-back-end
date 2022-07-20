import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

void main(List<String> arguments) async {
  final server = await io.serve(_handler, '0.0.0.0', 8080);

  print("[SERVER] Running on port ${server.port}");
}

FutureOr<Response> _handler(Request request) {
  return Response(200, body: 'Body');
}
