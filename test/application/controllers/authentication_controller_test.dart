import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travue/application/controllers/authentication_controller.dart';
import 'package:travue/domain/entities/user.dart' as domain;
import 'package:travue/domain/repositories/authentication_repository.dart';
import '../../helpers/test_setup.dart';

class MockAuthenticationRepository implements AuthenticationRepository {
  domain.User? _currentUser;
  
  void setCurrentUser(domain.User? user) {
    _currentUser = user;
  }
  
  @override
  domain.User? get currentUser => _currentUser;
  
  @override
  Stream<domain.User?> get authStateChanges {
    return Stream.value(_currentUser);
  }
  
  @override
  Future<domain.User?> signInWithEmail(String email, String password) async {
    if (email == 'test@example.com' && password == 'password123') {
      final user = domain.User(
        id: 'test-user-id',
        email: email,
        username: 'testuser',
        displayName: 'Test User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      setCurrentUser(user);
      return user;
    }
    throw AuthException('Invalid credentials');
  }
  
  @override
  Future<domain.User?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final user = domain.User(
      id: 'new-user-id',
      email: email,
      username: email.split('@').first,
      displayName: displayName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    setCurrentUser(user);
    return user;
  }
  
  @override
  Future<domain.User?> signInWithProvider(OAuthProvider provider) async {
    final user = domain.User(
      id: 'oauth-user-id',
      email: 'oauth@example.com',
      username: 'oauthuser',
      displayName: 'OAuth User',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    setCurrentUser(user);
    return user;
  }
  
  @override
  Future<void> signOut() async {
    setCurrentUser(null);
  }
  
  @override
  Future<void> resetPassword(String email) async {
    // Mock implementation - do nothing
  }
}

void main() {
  setupTestEnvironment();
  
  group('AuthenticationController', () {
    late MockAuthenticationRepository mockRepository;
    late AuthenticationController controller;
    late ProviderContainer container;
    
    setUp(() {
      mockRepository = MockAuthenticationRepository();
      container = ProviderContainer();
      controller = AuthenticationController(mockRepository);
    });
    
    tearDown(() {
      controller.dispose();
      container.dispose();
    });
    
    test('initial state should be data with null user', () async {
      // Wait for initialization
      await Future.delayed(Duration.zero);
      
      expect(controller.state, isA<AsyncData<domain.User?>>());
      expect(controller.state.value, isNull);
    });
    
    test('signInWithEmail should update state correctly on success', () async {
      await controller.signInWithEmail('test@example.com', 'password123');
      
      expect(controller.state, isA<AsyncData<domain.User?>>());
      expect(controller.state.value, isNotNull);
      expect(controller.state.value?.email, equals('test@example.com'));
      expect(controller.state.value?.displayName, equals('Test User'));
    });
    
    test('signInWithEmail should handle error correctly', () async {
      await controller.signInWithEmail('invalid@example.com', 'wrongpassword');
      
      expect(controller.state, isA<AsyncError<domain.User?>>());
      expect(controller.state.error, isA<AuthException>());
    });
    
    test('signUpWithEmail should create new user', () async {
      await controller.signUpWithEmail(
        email: 'new@example.com',
        password: 'password123',
        displayName: 'New User',
      );
      
      expect(controller.state, isA<AsyncData<domain.User?>>());
      expect(controller.state.value, isNotNull);
      expect(controller.state.value?.email, equals('new@example.com'));
      expect(controller.state.value?.displayName, equals('New User'));
    });
    
    test('signInWithProvider should work with OAuth', () async {
      await controller.signInWithProvider(OAuthProvider.google);
      
      expect(controller.state, isA<AsyncData<domain.User?>>());
      expect(controller.state.value, isNotNull);
      expect(controller.state.value?.email, equals('oauth@example.com'));
    });
    
    test('signOut should clear user state', () async {
      // First sign in
      await controller.signInWithEmail('test@example.com', 'password123');
      expect(controller.state.value, isNotNull);
      
      // Then sign out
      await controller.signOut();
      expect(controller.state, isA<AsyncData<domain.User?>>());
      expect(controller.state.value, isNull);
    });
    
    test('resetPassword should not throw error', () async {
      expect(
        () => controller.resetPassword('test@example.com'),
        returnsNormally,
      );
    });
    
    test('controller should listen to auth state changes', () async {
      // Initially no user
      expect(controller.state.value, isNull);
      
      // Sign in should update state through auth state changes
      await controller.signInWithEmail('test@example.com', 'password123');
      
      expect(controller.state.value, isNotNull);
      expect(controller.state.value?.email, equals('test@example.com'));
    });
  });
}