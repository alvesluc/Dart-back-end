import '../../../core/services/database/remote_database.dart';
import '../../../utils/to_query_extension.dart';
import '../repositories/auth_repository.dart';

class AuthDatasourceImpl implements AuthDatasource {
  final RemoteDatabase database;

  AuthDatasourceImpl(this.database);

  @override
  Future<Map> getIdRoleAndPasswordByEmail(String email) async {
    final result = await database.query(
      '''
      SELECT id, role, password
      FROM "User" WHERE email = @email;
      '''
          .toQuery(),
      variables: {'email': email},
    );

    if (result.isEmpty) {
      return {};
    }

    return result.map((e) => e['User']).first!;
  }

  @override
  Future<String> getRoleById(id) async {
    final result = await database.query(
      '''
      SELECT role
      FROM "User" WHERE id = @id;
      '''
          .toQuery(),
      variables: {'id': id},
    );

    return result.map((e) => e['User']).first!['role'];
  }

  @override
  Future<String> getPasswordHashById(id) async {
    final result = await database.query(
      '''
      SELECT password
      FROM "User" WHERE id = @id;
      '''
          .toQuery(),
      variables: {'id': id},
    );

    return result.map((e) => e['User']).first!['password'];
  }

  @override
  Future<void> updatePasswordHashById(id, String newPassword) async {
    await database.query(
      '''
      UPDATE "User" SET password=@password
      WHERE id = @id;
      '''
          .toQuery(),
      variables: {
        'id': id,
        'password': newPassword,
      },
    );
  }
}
