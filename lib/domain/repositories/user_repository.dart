import '../entities/user.dart';

abstract class UserRepository {
  Future<User?> getCurrentUser();
  Future<User?> getUserById(String id);
  Future<User?> getUserByUsername(String username);
  Future<User> createUser(User user);
  Future<User> updateUser(User user);
  Future<void> deleteUser(String id);
  Future<List<User>> searchUsers(String query);
}