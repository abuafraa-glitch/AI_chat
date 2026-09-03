import 'package:ai_chat/data/datasources/remote/remote_data_source.dart';
import 'package:ai_chat/data/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl({required RemoteDataSource remoteDataSource})
    : _remote = remoteDataSource;

  final RemoteDataSource _remote;

  @override
  Future<Map<String, dynamic>> getCurrentUser() => _remote.getCurrentUser();
}
