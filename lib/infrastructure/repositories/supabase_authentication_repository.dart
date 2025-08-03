import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/authentication_repository.dart';

class SupabaseAuthenticationRepository implements AuthenticationRepository {
  final supabase.SupabaseClient _client;
  
  SupabaseAuthenticationRepository(this._client);
  
  @override
  Future<domain.User?> signInWithEmail(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (response.user != null) {
      return _mapSupabaseUserToUser(response.user!);
    }
    return null;
  }
  
  @override
  Future<domain.User?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName},
    );
    
    if (response.user != null) {
      return _mapSupabaseUserToUser(response.user!);
    }
    return null;
  }
  
  @override
  Future<domain.User?> signInWithProvider(supabase.OAuthProvider provider) async {
    await _client.auth.signInWithOAuth(provider);
    final user = _client.auth.currentUser;
    return user != null ? _mapSupabaseUserToUser(user) : null;
  }
  
  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  @override
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
  
  @override
  Stream<domain.User?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      return user != null ? _mapSupabaseUserToUser(user) : null;
    });
  }
  
  @override
  domain.User? get currentUser {
    final user = _client.auth.currentUser;
    return user != null ? _mapSupabaseUserToUser(user) : null;
  }
  
  domain.User _mapSupabaseUserToUser(supabase.User supabaseUser) {
    return domain.User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      username: supabaseUser.userMetadata?['username'] ?? supabaseUser.email?.split('@').first ?? '',
      displayName: supabaseUser.userMetadata?['display_name'] ?? '',
      avatarUrl: supabaseUser.userMetadata?['avatar_url'],
      createdAt: DateTime.parse(supabaseUser.createdAt),
      updatedAt: DateTime.now(),
    );
  }
}