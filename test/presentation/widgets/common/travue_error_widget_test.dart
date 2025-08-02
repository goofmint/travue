import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travue/presentation/widgets/common/travue_error_widget.dart';

void main() {
  group('TravueErrorWidget', () {
    testWidgets('displays error message correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TravueErrorWidget(
              message: 'Test error message',
            ),
          ),
        ),
      );

      expect(find.text('Test error message'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays title when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TravueErrorWidget(
              title: 'Error Title',
              message: 'Test error message',
            ),
          ),
        ),
      );

      expect(find.text('Error Title'), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
    });

    testWidgets('displays custom icon when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TravueErrorWidget(
              icon: Icons.warning,
              message: 'Test error message',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('displays retry button when onRetry is provided', (tester) async {
      bool retryWasCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TravueErrorWidget(
              message: 'Test error message',
              onRetry: () {
                retryWasCalled = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryWasCalled, isTrue);
    });

    testWidgets('displays custom retry button text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TravueErrorWidget(
              message: 'Test error message',
              retryButtonText: 'Try Again',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('does not display retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TravueErrorWidget(
              message: 'Test error message',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.refresh), findsNothing);
      expect(find.text('Retry'), findsNothing);
    });
  });
}