import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travue/presentation/widgets/common/travue_text_field.dart';

void main() {
  group('TravueTextField', () {
    testWidgets('displays label text correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TravueTextField(
              label: 'Test Label',
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('displays hint text correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TravueTextField(
              hintText: 'Test Hint',
            ),
          ),
        ),
      );

      expect(find.text('Test Hint'), findsOneWidget);
    });

    testWidgets('displays prefix icon when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TravueTextField(
              prefixIcon: Icons.email,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('displays suffix icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TravueTextField(
              suffixIcon: Icons.visibility,
              onSuffixIconTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('calls onSuffixIconTap when suffix icon is tapped', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TravueTextField(
              suffixIcon: Icons.visibility,
              onSuffixIconTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('handles text input correctly', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TravueTextField(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Test Input');
      expect(controller.text, equals('Test Input'));
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String changedText = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TravueTextField(
              onChanged: (value) {
                changedText = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'New Text');
      expect(changedText, equals('New Text'));
    });

    testWidgets('validates input correctly', (tester) async {
      String? validationResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: TravueTextField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      final formState = tester.state<FormState>(find.byType(Form));
      validationResult = formState.validate() ? null : 'Validation failed';

      expect(validationResult, equals('Validation failed'));
    });

    testWidgets('shows error text when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TravueTextField(
              errorText: 'Error message',
            ),
          ),
        ),
      );

      expect(find.text('Error message'), findsOneWidget);
    });
  });
}