import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travue/presentation/widgets/common/travue_button.dart';

void main() {
  group('TravueButton', () {
    testWidgets('displays text correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TravueButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('displays icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TravueButton(
              text: 'Test Button',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TravueButton(
              text: 'Test Button',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test Button'), findsNothing);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TravueButton(
              text: 'Test Button',
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TravueButton));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TravueButton(
              text: 'Test Button',
              onPressed: null,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('renders different button types correctly', (tester) async {
      // Test primary button
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TravueButton(
              text: 'Primary',
              type: TravueButtonType.primary,
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Test outlined button
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TravueButton(
              text: 'Outlined',
              type: TravueButtonType.outlined,
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);

      // Test text button
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TravueButton(
              text: 'Text',
              type: TravueButtonType.text,
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.byType(TextButton), findsOneWidget);
    });
  });
}