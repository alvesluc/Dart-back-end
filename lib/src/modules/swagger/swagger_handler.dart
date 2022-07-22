import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf_swagger_ui/shelf_swagger_ui.dart';

FutureOr<Response> swaggerHandler(Request request) {
  final path = 'specs/swagger.yaml';
  final handler = SwaggerUI(
    path,
    title: 'Backend week',
    deepLink: true,
  );
  return handler(request);
}
