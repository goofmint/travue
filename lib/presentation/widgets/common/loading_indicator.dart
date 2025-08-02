import 'package:flutter/material.dart';

enum LoadingIndicatorSize {
  small,
  medium,
  large,
}

class LoadingIndicator extends StatelessWidget {
  final LoadingIndicatorSize size;
  final Color? color;
  final String? message;

  const LoadingIndicator({
    super.key,
    this.size = LoadingIndicatorSize.medium,
    this.color,
    this.message,
  });

  double get _indicatorSize {
    return switch (size) {
      LoadingIndicatorSize.small => 20,
      LoadingIndicatorSize.medium => 32,
      LoadingIndicatorSize.large => 48,
    };
  }

  double get _strokeWidth {
    return switch (size) {
      LoadingIndicatorSize.small => 2,
      LoadingIndicatorSize.medium => 3,
      LoadingIndicatorSize.large => 4,
    };
  }

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox(
      width: _indicatorSize,
      height: _indicatorSize,
      child: CircularProgressIndicator(
        strokeWidth: _strokeWidth,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );

    if (message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return indicator;
  }
}