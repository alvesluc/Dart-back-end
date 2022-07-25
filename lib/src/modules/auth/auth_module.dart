import 'package:shelf_modular/shelf_modular.dart';

import '../../core/services/database/postgres/postgres_database.dart';
import '../../core/services/database/remote_database.dart';
import '../../core/services/dot_env/dot_env_service.dart';
import 'datasources/auth_datasource_imp.dart';
import 'repositories/auth_repository.dart';
import 'resources/auth_resource.dart';

class AuthModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.singleton<DotEnvService>((i) => DotEnvService()),
        Bind.singleton<RemoteDatabase>((i) => PostgresDatabase(i())),
        Bind.singleton<AuthDatasource>((i) => AuthDatasourceImpl(i())),
        Bind.singleton((i) => AuthRepository(i(), i(), i())),
      ];

  @override
  List<ModularRoute> get routes => [
        Route.resource(AuthResource()),
      ];
}
