import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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
}