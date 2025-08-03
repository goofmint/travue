import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ScreenSize {
  mobile,
  tablet,
  desktop,
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final double? mobileBreakpoint;
  final double? tabletBreakpoint;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.mobileBreakpoint,
    this.tabletBreakpoint,
  });

  static ScreenSize getScreenSize(BuildContext context, {double? mobileBreakpoint, double? tabletBreakpoint}) {
    final width = MediaQuery.of(context).size.width;
    final tabletBreak = tabletBreakpoint ?? 1200;
    final mobileBreak = mobileBreakpoint ?? 768;
    
    if (width >= tabletBreak) {
      return ScreenSize.desktop;
    } else if (width >= mobileBreak) {
      return ScreenSize.tablet;
    } else {
      return ScreenSize.mobile;
    }
  }

  static bool isMobile(BuildContext context) {
    return getScreenSize(context) == ScreenSize.mobile;
  }

  static bool isTablet(BuildContext context) {
    return getScreenSize(context) == ScreenSize.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return getScreenSize(context) == ScreenSize.desktop;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(
      context,
      mobileBreakpoint: mobileBreakpoint,
      tabletBreakpoint: tabletBreakpoint,
    );
    
    return switch (screenSize) {
      ScreenSize.desktop => desktop ?? tablet ?? mobile,
      ScreenSize.tablet => tablet ?? mobile,
      ScreenSize.mobile => mobile,
    };
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSize screenSize) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, ResponsiveLayout.getScreenSize(context));
  }
}

extension ResponsiveExtensions on num {
  double get w => ScreenUtil().setWidth(this);
  double get h => ScreenUtil().setHeight(this);
  double get sp => ScreenUtil().setSp(this);
  double get r => ScreenUtil().radius(this);
}