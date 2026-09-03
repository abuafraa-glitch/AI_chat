import 'package:ai_chat/data/datasources/remote/remote_data_source.dart';
import 'package:ai_chat/data/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required RemoteDataSource remoteDataSource})
    : _remote = remoteDataSource;

  final RemoteDataSource _remote;

  @override
  Future<Map<String, dynamic>> login({required String email, required String password}) =>
      _remote.login(email: email, password: password);

  @override
  Future<Map<String, dynamic>> register({required String name, required String email, required String password}) =>
      _remote.register(name: name, email: email, password: password);

  @override
  Future<Map<String, dynamic>> socialLogin({required String provider, required String token}) =>
      _remote.socialLogin(provider: provider, token: token);

  @override
  Future<void> logout() => _remote.logout();

  @override
  Future<Map<String, dynamic>> getCurrentUser() => _remote.getCurrentUser();

  @override
  Future<void> forgotPassword(String email) => _remote.forgotPassword(email);

  @override
  Future<void> resetPassword({required String email, required String token, required String password}) =>
      _remote.resetPassword(email: email, token: token, password: password);

  @override
  Future<void> verifyEmail({required String email, required String code}) =>
      _remote.verifyEmail(email: email, code: code);

  @override
  Future<void> resendVerification(String email) => _remote.resendVerification(email);
}
