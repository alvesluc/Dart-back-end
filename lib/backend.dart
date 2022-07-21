import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import 'src/app_module.dart';

Future<Handler> startShelfModular() async {
  final handler = Modular(
    module: AppModule(),
    middlewares: [
      logRequests(),
    ],
  );

  return handler;
}
