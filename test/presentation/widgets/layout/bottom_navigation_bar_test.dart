import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travue/presentation/widgets/layout/bottom_navigation_bar.dart';

void main() {
  group('TravueBottomNavigationBar', () {
    final testItems = [
      const TravueBottomNavigationItem(
        icon: Icons.home,
        label: 'Home',
        route: '/',
      ),
      const TravueBottomNavigationItem(
        icon: Icons.search,
        label: 'Search',
        route: '/search',
      ),
      const TravueBottomNavigationItem(
        icon: Icons.person,
        label: 'Profile',
        route: '/profile',
      ),
    ];

    testWidgets('displays all navigation items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: TravueBottomNavigationBar(
              items: testItems,
              currentIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('highlights current index correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: TravueBottomNavigationBar(
              items: testItems,
              currentIndex: 1,
              onTap: (_) {},
            ),
          ),
        ),
      );

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.currentIndex, equals(1));
    });

    testWidgets('calls onTap when item is tapped', (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: TravueBottomNavigationBar(
              items: testItems,
              currentIndex: 0,
              onTap: (index) {
                tappedIndex = index;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Search'));
      await tester.pump();

      expect(tappedIndex, equals(1));

      await tester.tap(find.text('Profile'));
      await tester.pump();

      expect(tappedIndex, equals(2));
    });

    testWidgets('uses active icon when provided', (tester) async {
      final itemsWithActiveIcons = [
        const TravueBottomNavigationItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
          route: '/',
        ),
        const TravueBottomNavigationItem(
          icon: Icons.search_outlined,
          activeIcon: Icons.search,
          label: 'Search',
          route: '/search',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: TravueBottomNavigationBar(
              items: itemsWithActiveIcons,
              currentIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      // Active icon should be shown for selected item
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsNothing);
      
      // Inactive icon should be shown for non-selected item
      expect(find.byIcon(Icons.search_outlined), findsOneWidget);
      expect(find.byIcon(Icons.search), findsNothing);
    });

    testWidgets('applies custom colors when provided', (tester) async {
      const selectedColor = Colors.blue;
      const unselectedColor = Colors.grey;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: TravueBottomNavigationBar(
              items: testItems,
              currentIndex: 0,
              onTap: (_) {},
              selectedItemColor: selectedColor,
              unselectedItemColor: unselectedColor,
            ),
          ),
        ),
      );

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.selectedItemColor, equals(selectedColor));
      expect(bottomNavBar.unselectedItemColor, equals(unselectedColor));
    });

    testWidgets('applies custom background color when provided', (tester) async {
      const backgroundColor = Colors.black;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: TravueBottomNavigationBar(
              items: testItems,
              currentIndex: 0,
              onTap: (_) {},
              backgroundColor: backgroundColor,
            ),
          ),
        ),
      );

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.backgroundColor, equals(backgroundColor));
    });

    testWidgets('has fixed type for consistent layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: TravueBottomNavigationBar(
              items: testItems,
              currentIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.type, equals(BottomNavigationBarType.fixed));
    });

    testWidgets('handles minimum two items', (tester) async {
      final minItems = [
        const TravueBottomNavigationItem(
          icon: Icons.home,
          label: 'Home',
          route: '/',
        ),
        const TravueBottomNavigationItem(
          icon: Icons.search,
          label: 'Search',
          route: '/search',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: TravueBottomNavigationBar(
              items: minItems,
              currentIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });
  });
}