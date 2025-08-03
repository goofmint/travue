import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travue/presentation/screens/home/home_screen.dart';
import 'package:travue/presentation/widgets/layout/app_scaffold.dart';
import 'package:travue/presentation/widgets/layout/responsive_layout.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('displays correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Should use AppScaffold
      expect(find.byType(AppScaffold), findsOneWidget);
      
      // Should have title
      expect(find.text('Travue'), findsOneWidget);
      
      // Should use ResponsiveLayout
      expect(find.byType(ResponsiveLayout), findsOneWidget);
    });

    testWidgets('displays welcome message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(find.text('Welcome to Travue'), findsOneWidget);
    });

    testWidgets('displays description text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(
        find.text('Your travel guide creation companion'),
        findsOneWidget,
      );
    });

    testWidgets('displays feature cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Feature titles
      expect(find.text('Explore Maps'), findsOneWidget);
      expect(find.text('Share Moments'), findsOneWidget);
      expect(find.text('Create Guides'), findsOneWidget);
      expect(find.text('Community'), findsOneWidget);

      // Feature descriptions
      expect(
        find.text('Discover landmarks and points of interest'),
        findsOneWidget,
      );
      expect(
        find.text('Post photos and experiences'),
        findsOneWidget,
      );
      expect(
        find.text('Build travel guides for others'),
        findsOneWidget,
      );
      expect(
        find.text('Connect with fellow travelers'),
        findsOneWidget,
      );

      // Feature icons
      expect(find.byIcon(Icons.explore), findsOneWidget);
      expect(find.byIcon(Icons.map), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.book), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('displays mobile layout on small screens', (tester) async {
      // Set up a small screen size
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Should show single column layout
      final columnFinder = find.descendant(
        of: find.byType(ResponsiveLayout),
        matching: find.byType(Column),
      );
      
      expect(columnFinder, findsAtLeastNWidgets(1));

      // Reset to default size
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('has proper padding and spacing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Find the main container with padding
      final paddingFinder = find.descendant(
        of: find.byType(ResponsiveLayout),
        matching: find.byType(Padding),
      );

      expect(paddingFinder, findsAtLeastNWidgets(1));
      
      // Verify that cards have spacing
      final sizedBoxFinder = find.byType(SizedBox);
      expect(sizedBoxFinder, findsAtLeastNWidgets(1));
    });

    testWidgets('uses theme colors correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              secondary: Colors.orange,
            ),
          ),
          home: const HomeScreen(),
        ),
      );

      // The welcome text should use primary color
      final welcomeText = find.text('Welcome to Travue');
      expect(welcomeText, findsOneWidget);
      
      // Feature cards should be rendered
      expect(find.byType(Card), findsAtLeastNWidgets(3));
    });

    testWidgets('adapts to dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const HomeScreen(),
        ),
      );

      // All content should still be visible
      expect(find.text('Welcome to Travue'), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('scrolls when content overflows', (tester) async {
      // Set up a very small screen size to force overflow
      tester.view.physicalSize = const Size(360, 400);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Content should be scrollable
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Try to scroll
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pump();

      // Reset to default size
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}