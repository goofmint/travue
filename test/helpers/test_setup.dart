import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sets up the test environment with necessary platform channel mocks
void setupTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Mock the shared_preferences plugin
  const MethodChannel channel = MethodChannel('plugins.flutter.io/shared_preferences');
  
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    if (methodCall.method == 'getAll') {
      return <String, dynamic>{};
    }
    return null;
  });
  
  // Mock the path_provider plugin
  const MethodChannel pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'getApplicationDocumentsDirectory':
        return '/tmp';
      case 'getTemporaryDirectory':
        return '/tmp';
      case 'getApplicationSupportDirectory':
        return '/tmp';
      default:
        return null;
    }
  });
}