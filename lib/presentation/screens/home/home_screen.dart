import 'package:flutter/material.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../../widgets/common/travue_button.dart';
import '../../widgets/common/travue_card.dart';
import '../../widgets/layout/responsive_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Travue'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ResponsiveLayout(
        mobile: const _MobileHomeView(),
        tablet: const _TabletHomeView(),
        desktop: const _DesktopHomeView(),
      ),
    );
  }
}

class _MobileHomeView extends StatelessWidget {
  const _MobileHomeView();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WelcomeSection(),
          SizedBox(height: 24),
          _FeatureGrid(),
        ],
      ),
    );
  }
}

class _TabletHomeView extends StatelessWidget {
  const _TabletHomeView();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WelcomeSection(),
          SizedBox(height: 32),
          _FeatureGrid(),
        ],
      ),
    );
  }
}

class _DesktopHomeView extends StatelessWidget {
  const _DesktopHomeView();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _WelcomeSection(),
          ),
          SizedBox(width: 32),
          Expanded(
            flex: 3,
            child: _FeatureGrid(),
          ),
        ],
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    return TravueCard(
      child: Column(
        children: [
          const Icon(
            Icons.explore,
            size: 100,
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome to Travue',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Your travel guide creation companion',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TravueButton(
            text: 'Get Started',
            type: TravueButtonType.primary,
            icon: Icons.arrow_forward,
            isFullWidth: true,
            onPressed: () {
              // TODO: Navigate to onboarding or main features
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    final features = [
      _FeatureItem(
        icon: Icons.map,
        title: 'Explore Maps',
        description: 'Discover landmarks and points of interest',
        onTap: () {
          // TODO: Navigate to map screen
        },
      ),
      _FeatureItem(
        icon: Icons.camera_alt,
        title: 'Share Moments',
        description: 'Post photos and experiences',
        onTap: () {
          // TODO: Navigate to camera/post creation
        },
      ),
      _FeatureItem(
        icon: Icons.book,
        title: 'Create Guides',
        description: 'Build travel guides for others',
        onTap: () {
          // TODO: Navigate to guide creation
        },
      ),
      _FeatureItem(
        icon: Icons.people,
        title: 'Community',
        description: 'Connect with fellow travelers',
        onTap: () {
          // TODO: Navigate to community features
        },
      ),
    ];

    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final crossAxisCount = switch (screenSize) {
          ScreenSize.mobile => 2,
          ScreenSize.tablet => 3,
          ScreenSize.desktop => 4,
        };

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) => features[index],
        );
      },
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TravueCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}