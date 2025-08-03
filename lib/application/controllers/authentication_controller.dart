import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../../domain/entities/user.dart' as domain;

class AuthenticationController extends StateNotifier<AsyncValue<domain.User?>> {
  final AuthenticationRepository _repository;
  
  AuthenticationController(this._repository) : super(const AsyncValue.loading()) {
    _initialize();
  }
  
  void _initialize() {
    final currentUser = _repository.currentUser;
    state = AsyncValue.data(currentUser);
    
    // Listen to auth state changes
    _repository.authStateChanges.listen((user) {
      state = AsyncValue.data(user);
    });
  }
  
  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _repository.signInWithEmail(email, password);
    });
  }
  
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _repository.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
    });
  }
  
  Future<void> signInWithProvider(OAuthProvider provider) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _repository.signInWithProvider(provider);
    });
  }
  
  Future<void> signOut() async {
    await _repository.signOut();
    state = const AsyncValue.data(null);
  }
  
  Future<void> resetPassword(String email) async {
    await _repository.resetPassword(email);
  }
}