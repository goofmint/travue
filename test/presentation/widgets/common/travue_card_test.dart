import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travue/presentation/widgets/common/travue_card.dart';

void main() {
  group('TravueCard', () {
    testWidgets('displays child widget correctly', (tester) async {
      const testChild = Text('Test Child');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TravueCard(
              child: testChild,
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('applies custom padding', (tester) async {
      const customPadding = EdgeInsets.all(24);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TravueCard(
              padding: customPadding,
              child: Text('Test'),
            ),
          ),
        ),
      );

      final paddingFinder = find.descendant(
        of: find.byType(Card),
        matching: find.byType(Padding),
      );
      
      // Find the Padding widget with our custom padding
      final paddingWidgets = tester.widgetList<Padding>(paddingFinder);
      final customPaddingWidget = paddingWidgets.firstWhere(
        (widget) => widget.padding == customPadding,
      );

      expect(customPaddingWidget.padding, equals(customPadding));
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TravueCard(
              onTap: () {
                wasTapped = true;
              },
              child: const Text('Test'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('does not create InkWell when onTap is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TravueCard(
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('applies custom elevation', (tester) async {
      const customElevation = 8.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TravueCard(
              elevation: customElevation,
              child: Text('Test'),
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, equals(customElevation));
    });
  });
}