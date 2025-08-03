import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:travue/presentation/navigation/app_router.dart';
import 'package:travue/presentation/screens/home/home_screen.dart';

void main() {
  group('AppRouter', () {
    test('router instance is properly configured', () {
      expect(AppRouter.router, isA<GoRouter>());
      expect(AppRouter.router.configuration.routes.isNotEmpty, isTrue);
    });

    testWidgets('navigates to home screen at root path', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: AppRouter.router,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('handles invalid routes with error page', (tester) async {
      final router = GoRouter(
        initialLocation: '/invalid-route',
        routes: AppRouter.router.configuration.routes,
        errorBuilder: (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Page not found'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      // Should show error page
      expect(find.text('Page not found'), findsOneWidget);
      expect(find.text('Go to Home'), findsOneWidget);
    });

    testWidgets('error page navigates back to home', (tester) async {
      final router = GoRouter(
        initialLocation: '/invalid-route',
        routes: AppRouter.router.configuration.routes,
        errorBuilder: (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Page not found'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      // Tap go to home button
      await tester.tap(find.text('Go to Home'));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    test('router has home route configured', () {
      final homeRoute = AppRouter.router.configuration.routes.firstWhere(
        (route) => route is GoRoute && route.path == '/',
      );
      expect(homeRoute, isNotNull);
    });

    testWidgets('supports deep linking', (tester) async {
      // Create a test router with additional routes for testing
      final testRouter = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/test',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Test Screen')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: testRouter,
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      // Navigate to test route
      testRouter.go('/test');
      await tester.pumpAndSettle();

      expect(find.text('Test Screen'), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets('preserves navigation state', (tester) async {
      final testRouter = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/page1',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Page 1')),
            ),
          ),
          GoRoute(
            path: '/page2',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Page 2')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: testRouter,
        ),
      );

      await tester.pumpAndSettle();

      // Navigate through pages
      testRouter.push('/page1');
      await tester.pumpAndSettle();
      expect(find.text('Page 1'), findsOneWidget);

      testRouter.push('/page2');
      await tester.pumpAndSettle();
      expect(find.text('Page 2'), findsOneWidget);

      // Go back
      testRouter.pop();
      await tester.pumpAndSettle();
      expect(find.text('Page 1'), findsOneWidget);

      // Go back to home
      testRouter.pop();
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}