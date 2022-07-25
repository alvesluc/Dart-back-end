import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import 'core/core_module.dart';
import 'modules/auth/auth_module.dart';
import 'modules/swagger/swagger_handler.dart';
import 'modules/user/user_resource.dart';

class AppModule extends Module {
  @override
  List<Module> get imports => [
        CoreModule(),
      ];

  @override
  List<ModularRoute> get routes => [
        Route.get('/', (Request request) => Response.ok('OK')),
        Route.get('/docs/**', swaggerHandler),
        Route.resource(UserResource()),
        Route.module('/auth', module: AuthModule()),
      ];
}
