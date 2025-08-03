# Task 1.7: エラーハンドリング基盤

## 概要

Travueアプリケーションの包括的なエラーハンドリングシステムを実装します。ユーザーフレンドリーなエラー表示、適切なログ記録、グローバルエラーキャッチ機能を提供し、アプリケーションの安定性とデバッグ効率を向上させます。

## 目標

- [ ] エラークラスの定義

## 実装内容

### 1. エラークラス定義

アプリケーション全体で使用する統一されたエラークラス体系を構築します。

```dart
// lib/domain/errors/app_error.dart
abstract class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;
  
  const AppError({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });
  
  @override
  String toString() => 'AppError: $message${code != null ? ' ($code)' : ''}';
}

class NetworkError extends AppError {
  const NetworkError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class AuthenticationError extends AppError {
  const AuthenticationError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class ValidationError extends AppError {
  final Map<String, String> fieldErrors;
  
  const ValidationError({
    required super.message,
    required this.fieldErrors,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class DatabaseError extends AppError {
  const DatabaseError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class LocationError extends AppError {
  const LocationError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class FileSystemError extends AppError {
  const FileSystemError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}
```

### 2. ErrorHandler実装

エラーの種類に応じた適切な処理とログ記録を行うハンドラーを実装します。

```dart
// lib/application/services/error_handler.dart
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../domain/errors/app_error.dart';

class ErrorHandler {
  static final Logger _logger = Logger('ErrorHandler');
  
  static void handleError(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppError) {
      _handleAppError(error);
    } else {
      _handleUnknownError(error, stackTrace);
    }
  }
  
  static void _handleAppError(AppError error) {
    _logError(error);
    
    switch (error.runtimeType) {
      case NetworkError:
        _handleNetworkError(error as NetworkError);
        break;
      case AuthenticationError:
        _handleAuthError(error as AuthenticationError);
        break;
      case ValidationError:
        _handleValidationError(error as ValidationError);
        break;
      case DatabaseError:
        _handleDatabaseError(error as DatabaseError);
        break;
      case LocationError:
        _handleLocationError(error as LocationError);
        break;
      case FileSystemError:
        _handleFileSystemError(error as FileSystemError);
        break;
      default:
        _handleGenericError(error);
    }
  }
  
  static void _handleNetworkError(NetworkError error) {
    _logger.warning('Network Error: ${error.message}');
    // ネットワークエラー固有の処理
  }
  
  static void _handleAuthError(AuthenticationError error) {
    _logger.warning('Authentication Error: ${error.message}');
    // 認証エラー固有の処理（リダイレクトなど）
  }
  
  static void _handleValidationError(ValidationError error) {
    _logger.info('Validation Error: ${error.message}');
    // バリデーションエラー固有の処理
  }
  
  static void _handleDatabaseError(DatabaseError error) {
    _logger.severe('Database Error: ${error.message}');
    // データベースエラー固有の処理
  }
  
  static void _handleLocationError(LocationError error) {
    _logger.warning('Location Error: ${error.message}');
    // 位置情報エラー固有の処理
  }
  
  static void _handleFileSystemError(FileSystemError error) {
    _logger.warning('FileSystem Error: ${error.message}');
    // ファイルシステムエラー固有の処理
  }
  
  static void _handleGenericError(AppError error) {
    _logger.warning('Generic App Error: ${error.message}');
    // 汎用エラー処理
  }
  
  static void _handleUnknownError(dynamic error, StackTrace? stackTrace) {
    _logger.severe('Unknown Error: $error', error, stackTrace);
    
    if (kDebugMode) {
      // デバッグモードでは詳細ログを出力
      print('Unknown Error Details: $error');
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }
  
  static void _logError(AppError error) {
    final logMessage = 'Error: ${error.message}'
        '${error.code != null ? ' (Code: ${error.code})' : ''}';
    
    if (error.originalError != null) {
      _logger.severe(logMessage, error.originalError, error.stackTrace);
    } else {
      _logger.warning(logMessage);
    }
  }
  
  static String getUserFriendlyMessage(AppError error) {
    switch (error.runtimeType) {
      case NetworkError:
        return 'インターネット接続を確認してください。';
      case AuthenticationError:
        return 'ログインに失敗しました。認証情報を確認してください。';
      case ValidationError:
        return '入力内容に問題があります。';
      case DatabaseError:
        return 'データの読み込みに失敗しました。しばらく後に再試行してください。';
      case LocationError:
        return '位置情報の取得に失敗しました。設定を確認してください。';
      case FileSystemError:
        return 'ファイルの処理に失敗しました。';
      default:
        return '予期しないエラーが発生しました。';
    }
  }
}
```

### 3. グローバルエラーハンドリング

Flutter アプリケーション全体でキャッチされないエラーを処理します。

```dart
// lib/application/services/global_error_handler.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'error_handler.dart';

class GlobalErrorHandler {
  static void initialize() {
    // Flutter フレームワークのエラーをキャッチ
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      ErrorHandler.handleError(details.exception, details.stack);
    };
    
    // Dart の非同期エラーをキャッチ
    PlatformDispatcher.instance.onError = (error, stack) {
      ErrorHandler.handleError(error, stack);
      return true;
    };
  }
  
  static Widget createErrorWidget(FlutterErrorDetails details) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'アプリケーションエラーが発生しました',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              kDebugMode 
                ? details.exception.toString()
                : '問題が解決しない場合は、アプリを再起動してください。',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4. エラー通知UI

ユーザーにエラーを表示するための統一されたUIコンポーネントを実装します。

```dart
// lib/presentation/widgets/common/error_dialog.dart
import 'package:flutter/material.dart';
import '../../../domain/errors/app_error.dart';
import '../../../application/services/error_handler.dart';

class ErrorDialog extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  
  const ErrorDialog({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
  });
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.error_outline,
        color: Colors.red,
        size: 48,
      ),
      title: const Text('エラーが発生しました'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ErrorHandler.getUserFriendlyMessage(error),
            textAlign: TextAlign.center,
          ),
          if (error.code != null) ...[
            const SizedBox(height: 8),
            Text(
              'エラーコード: ${error.code}',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: [
        if (onDismiss != null)
          TextButton(
            onPressed: onDismiss,
            child: const Text('閉じる'),
          ),
        if (onRetry != null)
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('再試行'),
          ),
      ],
    );
  }
  
  static Future<void> show(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialog(
        error: error,
        onRetry: onRetry,
        onDismiss: onDismiss ?? () => Navigator.of(context).pop(),
      ),
    );
  }
}
```

### 5. エラーバナー

一時的なエラーメッセージを表示するためのバナーコンポーネントです。

```dart
// lib/presentation/widgets/common/error_banner.dart
import 'package:flutter/material.dart';
import '../../../domain/errors/app_error.dart';
import '../../../application/services/error_handler.dart';

class ErrorBanner extends StatelessWidget {
  final AppError error;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;
  
  const ErrorBanner({
    super.key,
    required this.error,
    this.onDismiss,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade600,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'エラー',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ErrorHandler.getUserFriendlyMessage(error),
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red.shade700,
              ),
              child: const Text('再試行'),
            ),
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                color: Colors.red.shade600,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  static void show(
    BuildContext context,
    AppError error, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ErrorBanner(
          error: error,
          onRetry: onRetry,
          onDismiss: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
```

## 技術要件

### ログ設定

```dart
// lib/application/services/logging_service.dart
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';

class LoggingService {
  static void initialize() {
    Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
    Logger.root.onRecord.listen((record) {
      final message = '${record.time}: ${record.loggerName}: ${record.level.name}: ${record.message}';
      
      if (kDebugMode) {
        print(message);
        if (record.error != null) {
          print('Error: ${record.error}');
        }
        if (record.stackTrace != null) {
          print('StackTrace: ${record.stackTrace}');
        }
      }
      
      // プロダクションでは外部ログサービスに送信
      // _sendToLogService(record);
    });
  }
}
```

### エラー回復戦略

1. **自動リトライ**: ネットワークエラーに対する指数バックオフ
2. **キャッシュフォールバック**: データ取得失敗時のローカルキャッシュ使用
3. **グレースフルデグラデーション**: 機能の段階的な無効化
4. **ユーザー誘導**: 適切な代替手段の提示

### テスト実装

```dart
// test/application/services/error_handler_test.dart
void main() {
  group('ErrorHandler', () {
    test('handles NetworkError correctly', () {
      const error = NetworkError(
        message: 'Connection timeout',
        code: 'NETWORK_001',
      );
      
      expect(() => ErrorHandler.handleError(error), returnsNormally);
      expect(ErrorHandler.getUserFriendlyMessage(error), 
             equals('インターネット接続を確認してください。'));
    });
    
    test('handles AuthenticationError correctly', () {
      const error = AuthenticationError(
        message: 'Invalid credentials',
        code: 'AUTH_001',
      );
      
      expect(ErrorHandler.getUserFriendlyMessage(error), 
             equals('ログインに失敗しました。認証情報を確認してください。'));
    });
  });
}
```

## 完了条件

- [ ] エラークラスの定義

## 依存関係

- Task 1.1 (Flutter プロジェクト初期設定) の完了が必要

## 推定作業時間

- エラークラス設計・実装: 30分

**合計: 30分**（チェックボックス1つ分）

## 注意点

- エラーメッセージは日本語だが、ログやコードは英語で統一
- 本番環境では機密情報をログに出力しないよう注意
- エラーハンドリングがアプリケーションパフォーマンスに影響しないよう最適化
- ユーザビリティを損なわない適切なエラー表示タイミングの調整