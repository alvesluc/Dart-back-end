import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import 'core/services/bcrypt/bcrypt_service.dart';
import 'core/services/bcrypt/bcrypt_service_imp.dart';
import 'core/services/database/postgres/postgres_database.dart';
import 'core/services/database/remote_database.dart';
import 'core/services/dot_env/dot_env_service.dart';
import 'core/services/jwt/dart_jsonwebtoken/jwt_service_imp.dart';
import 'core/services/jwt/jwt_service.dart';
import 'core/services/request_extractor/request_extractor.dart';
import 'modules/auth/auth_resource.dart';
import 'modules/swagger/swagger_handler.dart';
import 'modules/user/user_resource.dart';

class AppModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.singleton<DotEnvService>((i) => DotEnvService()),
        Bind.singleton<RemoteDatabase>((i) => PostgresDatabase(i())),
        Bind.singleton<BCryptService>((i) => BCryptServiceImp()),
        Bind.singleton<JWTService>((i) => JWTServiceImp(i())),
        Bind.singleton<RequestExtractor>((i) => RequestExtractor()),
      ];

  @override
  List<ModularRoute> get routes => [
        Route.get('/', (Request request) => Response.ok('OK')),
        Route.get('/docs/**', swaggerHandler),
        Route.resource(UserResource()),
        Route.resource(AuthResource()),
      ];
}
