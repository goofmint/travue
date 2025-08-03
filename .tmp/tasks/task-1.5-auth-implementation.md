# Task 1.5: 認証基盤実装

## 概要

Supabase Authを使用してTravueアプリケーションの認証システムを実装します。Email、Google、Appleの3つの認証方法をサポートし、Riverpodによる状態管理とログイン永続化を実現します。

## 目標

- [ ] Supabase Auth の設定（Email, Google, Apple）

## 実装内容

### 1. Supabase Auth設定

#### 1.1 Email認証設定

Supabaseダッシュボードで以下の設定を行います：

1. Authentication → Providers → Email を有効化
2. Email Confirmationの設定
   - Confirm email: 有効
   - Email template設定（確認メール、パスワードリセット）
3. 最小パスワード長: 8文字

#### 1.2 Google OAuth設定

1. Google Cloud Consoleでプロジェクト作成
2. OAuth 2.0 クライアント IDを作成
   - アプリケーションタイプ: ウェブアプリケーション
   - 承認済みリダイレクトURI: `https://<project-ref>.supabase.co/auth/v1/callback`
3. Supabaseダッシュボードで設定
   - Google Provider有効化
   - Client ID/Secretを設定

#### 1.3 Apple Sign In設定

1. Apple Developer Programでの設定
   - App IDの作成（Sign in with Apple有効化）
   - Service IDの作成
   - Private Keyの生成
2. Supabaseダッシュボードで設定
   - Apple Provider有効化
   - Service ID、Team ID、Private Key設定

### 2. AuthenticationController実装

```dart
// lib/application/controllers/authentication_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../../domain/entities/user.dart';

class AuthenticationController extends StateNotifier<AsyncValue<User?>> {
  final AuthenticationRepository _repository;
  
  AuthenticationController(this._repository) : super(const AsyncValue.loading());
  
  // Email Sign In
  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _repository.signInWithEmail(email, password);
    });
  }
  
  // Email Sign Up
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
  
  // OAuth Sign In
  Future<void> signInWithProvider(OAuthProvider provider) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _repository.signInWithProvider(provider);
    });
  }
  
  // Sign Out
  Future<void> signOut() async {
    await _repository.signOut();
    state = const AsyncValue.data(null);
  }
  
  // Password Reset
  Future<void> resetPassword(String email) async {
    await _repository.resetPassword(email);
  }
}
```

### 3. Repository実装

```dart
// lib/domain/repositories/authentication_repository.dart
abstract class AuthenticationRepository {
  Future<User?> signInWithEmail(String email, String password);
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });
  Future<User?> signInWithProvider(OAuthProvider provider);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Stream<User?> get authStateChanges;
  User? get currentUser;
}
```

```dart
// lib/infrastructure/repositories/supabase_authentication_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class SupabaseAuthenticationRepository implements AuthenticationRepository {
  final SupabaseClient _client;
  
  SupabaseAuthenticationRepository(this._client);
  
  @override
  Future<User?> signInWithEmail(String email, String password) async {
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
  Future<User?> signInWithProvider(OAuthProvider provider) async {
    // Initiate the OAuth flow; returns after the external browser redirect completes.
    await _client.auth.signInWithOAuth(provider);
    final user = _client.auth.currentUser;
    return user != null ? _mapSupabaseUserToUser(user) : null;
  }
  
  @override
  Future<User?> signUpWithEmail({
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
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  @override
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
  
  @override
  Stream<User?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((data) {
      final user = data.user;
      return user != null ? _mapSupabaseUserToUser(user) : null;
    });
  }
  
  @override
  User? get currentUser {
    final user = _client.auth.currentUser;
    return user != null ? _mapSupabaseUserToUser(user) : null;
  }
  
  User _mapSupabaseUserToUser(supabase.User supabaseUser) {
    return User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      displayName: supabaseUser.userMetadata?['display_name'] ?? '',
      avatarUrl: supabaseUser.userMetadata?['avatar_url'],
      createdAt: DateTime.parse(supabaseUser.createdAt),
    );
  }
}
```

### 4. Riverpod Providers

```dart
// lib/application/providers/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/authentication_controller.dart';
import '../../infrastructure/repositories/supabase_authentication_repository.dart';
import '../../infrastructure/services/supabase_service.dart';

final authenticationRepositoryProvider = Provider<AuthenticationRepository>((ref) {
  final supabaseClient = SupabaseService.instance.client;
  return SupabaseAuthenticationRepository(supabaseClient);
});

final authenticationControllerProvider = 
    StateNotifierProvider<AuthenticationController, AsyncValue<User?>>((ref) {
  final repository = ref.watch(authenticationRepositoryProvider);
  return AuthenticationController(repository);
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authenticationControllerProvider);
  return authState.maybeWhen(
    data: (user) => user,
    orElse: () => null,
  );
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});
```

### 5. ログイン永続化

```dart
// lib/application/services/auth_persistence_service.dart
class AuthPersistenceService {
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserDisplayName = 'user_display_name';
  
  final SharedPreferences _prefs;
  
  AuthPersistenceService(this._prefs);
  
  Future<void> saveUserSession(User user) async {
    await _prefs.setString(_keyUserId, user.id);
    await _prefs.setString(_keyUserEmail, user.email);
    await _prefs.setString(_keyUserDisplayName, user.displayName);
  }
  
  Future<void> clearUserSession() async {
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserDisplayName);
  }
  
  User? getCachedUser() {
    final userId = _prefs.getString(_keyUserId);
    if (userId == null) return null;
    
    return User(
      id: userId,
      email: _prefs.getString(_keyUserEmail) ?? '',
      displayName: _prefs.getString(_keyUserDisplayName) ?? '',
      createdAt: DateTime.now(), // Placeholder
    );
  }
}
```

### 6. 認証画面UI

```dart
// lib/presentation/screens/auth/login_screen.dart
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      await ref.read(authenticationControllerProvider.notifier)
          .signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );
      
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _signInWithGoogle() async {
    try {
      await ref.read(authenticationControllerProvider.notifier)
          .signInWithProvider(OAuthProvider.google);
      
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign in failed: ${e.toString()}')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to Travue',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 32),
                TravueTextField(
                  controller: _emailController,
                  label: 'Email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TravueTextField(
                  controller: _passwordController,
                  label: 'Password',
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                TravueButton(
                  text: 'Sign In',
                  onPressed: _isLoading ? null : _signInWithEmail,
                  isLoading: _isLoading,
                  variant: TravueButtonVariant.primary,
                  isFullWidth: true,
                ),
                const SizedBox(height: 16),
                TravueButton(
                  text: 'Sign in with Google',
                  onPressed: _signInWithGoogle,
                  variant: TravueButtonVariant.secondary,
                  icon: Icons.g_mobiledata,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## 技術要件

### セキュリティ要件

1. **パスワード強度**: 最低8文字、英数字混在推奨
2. **セッション管理**: JWTトークンの適切な管理
3. **OAuth リダイレクト**: 承認済みURLのみ許可
4. **Email確認**: 新規登録時のメール認証必須

### エラーハンドリング

1. **認証エラー**:
   - 無効な認証情報
   - ネットワークエラー
   - メール未確認
   - アカウントロック

2. **エラーメッセージ**:
   - ユーザーフレンドリーなメッセージ表示
   - 詳細なログ記録（デバッグ用）

### テスト実装

```dart
// test/application/controllers/authentication_controller_test.dart
void main() {
  group('AuthenticationController', () {
    test('signInWithEmail updates state correctly', () async {
      // Mock repository
      final mockRepo = MockAuthenticationRepository();
      when(mockRepo.signInWithEmail(any, any))
          .thenAnswer((_) async => testUser);
      
      final controller = AuthenticationController(mockRepo);
      
      await controller.signInWithEmail('test@example.com', 'password123');
      
      expect(controller.state, isA<AsyncData<User>>());
      expect(controller.state.value?.email, equals('test@example.com'));
    });
  });
}
```

## 完了条件

- [ ] Supabase Auth の設定（Email, Google, Apple）

## 依存関係

- Task 1.2 (Supabase プロジェクトセットアップ) の完了が必要
- Task 1.3 (データベーススキーマ実装) の完了が必要

## 推定作業時間

- Supabase Auth設定: 1時間

**合計: 1時間**（チェックボックス1つ分）

## 注意点

- OAuth設定は開発環境と本番環境で異なるため、環境ごとに管理する
- Apple Sign Inは有料のApple Developer Programが必要
- Email認証のテンプレートはブランディングに合わせてカスタマイズする
- セキュリティを最優先に、パスワードの平文保存は絶対に避ける