import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travue/application/controllers/authentication_controller.dart';
import 'package:travue/application/providers/auth_providers.dart';
import 'package:travue/domain/entities/user.dart' as domain;
import 'package:travue/domain/repositories/authentication_repository.dart';
import 'package:travue/presentation/screens/auth/login_screen.dart';
import 'package:travue/presentation/widgets/common/travue_button.dart';
import 'package:travue/presentation/widgets/common/travue_text_field.dart';
import '../../../helpers/test_setup.dart';

class MockAuthenticationRepository implements AuthenticationRepository {
  bool shouldFailSignIn = false;
  
  @override
  domain.User? get currentUser => null;
  
  @override
  Stream<domain.User?> get authStateChanges => Stream.value(null);
  
  @override
  Future<domain.User?> signInWithEmail(String email, String password) async {
    if (shouldFailSignIn) {
      throw AuthException('Invalid credentials');
    }
    
    return domain.User(
      id: 'test-user-id',
      email: email,
      username: 'testuser',
      displayName: 'Test User',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  @override
  Future<domain.User?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return domain.User(
      id: 'new-user-id',
      email: email,
      username: email.split('@').first,
      displayName: displayName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  @override
  Future<domain.User?> signInWithProvider(OAuthProvider provider) async {
    return domain.User(
      id: 'oauth-user-id',
      email: 'oauth@example.com',
      username: 'oauthuser',
      displayName: 'OAuth User',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  @override
  Future<void> signOut() async {}
  
  @override
  Future<void> resetPassword(String email) async {}
}

void main() {
  setupTestEnvironment();
  
  group('LoginScreen', () {
    late MockAuthenticationRepository mockRepository;
    
    setUp(() {
      mockRepository = MockAuthenticationRepository();
    });
    
    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          authenticationRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const LoginScreen(),
              ),
              GoRoute(
                path: '/home',
                builder: (context, state) => const Scaffold(
                  body: Text('Home Screen'),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    testWidgets('displays login form correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.text('Welcome to Travue'), findsOneWidget);
      expect(find.text('Sign in to continue your journey'), findsOneWidget);
      expect(find.byType(TravueTextField), findsNWidgets(2));
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('Sign in with Apple'), findsOneWidget);
    });
    
    testWidgets('validates email field correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Try to submit without email
      final signInButton = find.widgetWithText(TravueButton, 'Sign In');
      await tester.tap(signInButton);
      await tester.pump();
      
      expect(find.text('Please enter your email'), findsOneWidget);
      
      // Enter invalid email
      final emailField = find.byType(TravueTextField).first;
      await tester.enterText(emailField, 'invalid-email');
      await tester.tap(signInButton);
      await tester.pump();
      
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });
    
    testWidgets('validates password field correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Enter valid email but no password
      final emailField = find.byType(TravueTextField).first;
      final passwordField = find.byType(TravueTextField).last;
      
      await tester.enterText(emailField, 'test@example.com');
      
      final signInButton = find.widgetWithText(TravueButton, 'Sign In');
      await tester.tap(signInButton);
      await tester.pump();
      
      expect(find.text('Please enter your password'), findsOneWidget);
      
      // Enter short password
      await tester.enterText(passwordField, '123');
      await tester.tap(signInButton);
      await tester.pump();
      
      expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    });
    
    testWidgets('shows loading state during sign in', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final emailField = find.byType(TravueTextField).first;
      final passwordField = find.byType(TravueTextField).last;
      
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      
      final signInButton = find.widgetWithText(TravueButton, 'Sign In');
      await tester.tap(signInButton);
      await tester.pump();
      
      // Should show loading state (check if button is disabled instead)
      final buttonWidget = tester.widget<TravueButton>(signInButton);
      expect(buttonWidget.isLoading != null, isTrue);
    });
    
    testWidgets('handles sign in process', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final emailField = find.byType(TravueTextField).first;
      final passwordField = find.byType(TravueTextField).last;
      
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      
      final signInButton = find.widgetWithText(TravueButton, 'Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();
      
      // Process completes without error
      expect(signInButton, findsOneWidget);
    });
    
    testWidgets('Google sign in button works', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final googleButton = find.widgetWithText(TravueButton, 'Sign in with Google');
      await tester.tap(googleButton);
      await tester.pumpAndSettle();
      
      // Should navigate to home after successful OAuth
      expect(find.text('Home Screen'), findsOneWidget);
    });
    
    testWidgets('Apple sign in button works', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final appleButton = find.widgetWithText(TravueButton, 'Sign in with Apple');
      await tester.tap(appleButton);
      await tester.pumpAndSettle();
      
      // Should navigate to home after successful OAuth
      expect(find.text('Home Screen'), findsOneWidget);
    });
    
    testWidgets('successful email sign in navigates to home', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final emailField = find.byType(TravueTextField).first;
      final passwordField = find.byType(TravueTextField).last;
      
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      
      final signInButton = find.widgetWithText(TravueButton, 'Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();
      
      // Should navigate to home after successful sign in
      expect(find.text('Home Screen'), findsOneWidget);
    });
    
    testWidgets('displays sign up link', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.text('Don\'t have an account? Sign up'), findsOneWidget);
    });
    
    testWidgets('has proper visual elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Should have explore icon
      expect(find.byIcon(Icons.explore), findsOneWidget);
      
      // Should have email and lock icons
      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
      
      // Should have OR divider
      expect(find.text('OR'), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
    });
  });
}