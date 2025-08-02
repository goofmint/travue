import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travue/presentation/widgets/common/loading_indicator.dart';

void main() {
  group('LoadingIndicator', () {
    testWidgets('displays circular progress indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(
              message: 'Loading data...',
            ),
          ),
        ),
      );

      expect(find.text('Loading data...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does not display message when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(),
          ),
        ),
      );

      expect(find.byType(Text), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('applies custom color', (tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(
              color: customColor,
            ),
          ),
        ),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.color, equals(customColor));
    });

    testWidgets('renders different sizes correctly', (tester) async {
      // Test small size
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(
              size: LoadingIndicatorSize.small,
            ),
          ),
        ),
      );

      SizedBox sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(LoadingIndicator),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, equals(20));
      expect(sizedBox.height, equals(20));

      // Test large size
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(
              size: LoadingIndicatorSize.large,
            ),
          ),
        ),
      );

      sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(LoadingIndicator),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, equals(48));
      expect(sizedBox.height, equals(48));
    });
  });
}