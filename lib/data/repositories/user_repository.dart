abstract interface class UserRepository {
  /// Returns the authenticated user's profile from the backend contract.
  Future<Map<String, dynamic>> getCurrentUser();
}
