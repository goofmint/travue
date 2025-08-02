import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../services/supabase_service.dart';

class SupabaseUserRepository implements UserRepository {
  final SupabaseService _supabaseService;

  SupabaseUserRepository(this._supabaseService);

  @override
  Future<User?> getCurrentUser() async {
    try {
      final authUser = _supabaseService.client.auth.currentUser;
      if (authUser == null) return null;

      final response = await _supabaseService.client
          .from('users')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      if (response == null) return null;
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Future<User?> getUserById(String id) async {
    try {
      final response = await _supabaseService.client
          .from('users')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user by id: $e');
    }
  }

  @override
  Future<User?> getUserByUsername(String username) async {
    try {
      final response = await _supabaseService.client
          .from('users')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (response == null) return null;
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user by username: $e');
    }
  }

  @override
  Future<User> createUser(User user) async {
    try {
      final response = await _supabaseService.client
          .from('users')
          .insert(user.toJson())
          .select()
          .single();

      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  @override
  Future<User> updateUser(User user) async {
    try {
      final response = await _supabaseService.client
          .from('users')
          .update(user.toJson())
          .eq('id', user.id)
          .select()
          .single();

      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await _supabaseService.client
          .from('users')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await _supabaseService.client
          .from('users')
          .select()
          .or('username.ilike.%$query%,display_name.ilike.%$query%')
          .limit(20);

      return response.map<User>((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
}