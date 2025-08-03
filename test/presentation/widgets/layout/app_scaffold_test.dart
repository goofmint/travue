import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travue/presentation/widgets/layout/app_scaffold.dart';

void main() {
  group('AppScaffold', () {
    testWidgets('displays title correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppScaffold(
            title: 'Test Title',
            body: Text('Test Body'),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays body content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppScaffold(
            body: Text('Test Body Content'),
          ),
        ),
      );

      expect(find.text('Test Body Content'), findsOneWidget);
    });

    testWidgets('shows AppBar when title is provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppScaffold(
            title: 'With AppBar',
            body: Text('Body'),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('hides AppBar when title is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppScaffold(
            body: Text('Body'),
          ),
        ),
      );

      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('displays leading widget when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppScaffold(
            title: 'Test',
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {},
            ),
            body: const Text('Body'),
          ),
        ),
      );

      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('displays actions when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppScaffold(
            title: 'Test',
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
            body: const Text('Body'),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('displays bottom navigation bar when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppScaffold(
            body: const Text('Body'),
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('displays floating action button when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppScaffold(
            body: const Text('Body'),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('applies padding when specified', (tester) async {
      const customPadding = EdgeInsets.all(20);

      await tester.pumpWidget(
        const MaterialApp(
          home: AppScaffold(
            body: Text('Body'),
            padding: customPadding,
          ),
        ),
      );

      final paddingFinder = find.descendant(
        of: find.byType(Scaffold),
        matching: find.byType(Padding),
      );

      expect(paddingFinder, findsOneWidget);
      final paddingWidget = tester.widget<Padding>(paddingFinder);
      expect(paddingWidget.padding, equals(customPadding));
    });

    testWidgets('handles drawer when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppScaffold(
            title: 'Test',
            drawer: const Drawer(
              child: Text('Drawer Content'),
            ),
            body: const Text('Body'),
          ),
        ),
      );

      // Find the scaffold
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      
      // Open drawer
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Drawer Content'), findsOneWidget);
    });
  });
}