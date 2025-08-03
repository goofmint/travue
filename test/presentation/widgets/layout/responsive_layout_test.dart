import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travue/presentation/widgets/layout/responsive_layout.dart';

void main() {
  group('ResponsiveLayout', () {
    testWidgets('displays mobile layout on small screens', (tester) async {
      // Set up a small screen size
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: Text('Mobile Layout'),
              tablet: Text('Tablet Layout'),
              desktop: Text('Desktop Layout'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsOneWidget);
      expect(find.text('Tablet Layout'), findsNothing);
      expect(find.text('Desktop Layout'), findsNothing);

      // Reset to default size
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays tablet layout on medium screens', (tester) async {
      // Set up a tablet screen size
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: Text('Mobile Layout'),
              tablet: Text('Tablet Layout'),
              desktop: Text('Desktop Layout'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsNothing);
      expect(find.text('Tablet Layout'), findsOneWidget);
      expect(find.text('Desktop Layout'), findsNothing);

      // Reset to default size
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays desktop layout on large screens', (tester) async {
      // Set up a desktop screen size
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: Text('Mobile Layout'),
              tablet: Text('Tablet Layout'),
              desktop: Text('Desktop Layout'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsNothing);
      expect(find.text('Tablet Layout'), findsNothing);
      expect(find.text('Desktop Layout'), findsOneWidget);

      // Reset to default size
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('falls back to mobile when tablet layout is not provided', (tester) async {
      // Set up a tablet screen size
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: Text('Mobile Layout'),
              desktop: Text('Desktop Layout'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsOneWidget);
      expect(find.text('Desktop Layout'), findsNothing);

      // Reset to default size
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('falls back to tablet when desktop layout is not provided', (tester) async {
      // Set up a desktop screen size
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: Text('Mobile Layout'),
              tablet: Text('Tablet Layout'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsNothing);
      expect(find.text('Tablet Layout'), findsOneWidget);

      // Reset to default size
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('updates layout when screen size changes', (tester) async {
      // Start with mobile size
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: Text('Mobile Layout'),
              tablet: Text('Tablet Layout'),
              desktop: Text('Desktop Layout'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsOneWidget);

      // Change to tablet size
      tester.view.physicalSize = const Size(768, 1024);
      await tester.pump();

      expect(find.text('Mobile Layout'), findsNothing);
      expect(find.text('Tablet Layout'), findsOneWidget);

      // Change to desktop size
      tester.view.physicalSize = const Size(1920, 1080);
      await tester.pump();

      expect(find.text('Tablet Layout'), findsNothing);
      expect(find.text('Desktop Layout'), findsOneWidget);

      // Reset to default size
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('respects custom breakpoints when provided', (tester) async {
      // Set up a screen size between default mobile and tablet
      tester.view.physicalSize = const Size(500, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: Text('Mobile Layout'),
              tablet: Text('Tablet Layout'),
              desktop: Text('Desktop Layout'),
              mobileBreakpoint: 550, // Custom breakpoint
              tabletBreakpoint: 1000, // Custom breakpoint
            ),
          ),
        ),
      );

      // Should show mobile layout because 500 < 550
      expect(find.text('Mobile Layout'), findsOneWidget);
      expect(find.text('Tablet Layout'), findsNothing);

      // Change to just above custom mobile breakpoint
      tester.view.physicalSize = const Size(600, 800);
      await tester.pump();

      // Should show tablet layout because 600 > 550
      expect(find.text('Mobile Layout'), findsNothing);
      expect(find.text('Tablet Layout'), findsOneWidget);

      // Reset to default size
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}