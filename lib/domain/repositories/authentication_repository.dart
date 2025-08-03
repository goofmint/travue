import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/user.dart' as domain;

abstract class AuthenticationRepository {
  Future<domain.User?> signInWithEmail(String email, String password);
  Future<domain.User?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });
  Future<domain.User?> signInWithProvider(OAuthProvider provider);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Stream<domain.User?> get authStateChanges;
  domain.User? get currentUser;
}