abstract interface class AuthRepository {
  Future<Map<String, dynamic>> login({required String email, required String password});
  Future<Map<String, dynamic>> register({required String name, required String email, required String password});
  Future<Map<String, dynamic>> socialLogin({required String provider, required String token});
  Future<void> logout();
  Future<Map<String, dynamic>> getCurrentUser();
  Future<void> forgotPassword(String email);
  Future<void> resetPassword({required String email, required String token, required String password});
  Future<void> verifyEmail({required String email, required String code});
  Future<void> resendVerification(String email);
}
