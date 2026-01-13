import 'package:flutter/material.dart';
import 'package:kairo/core/theme/theme.dart';
import 'package:kairo/core/utils/constants.dart';

/// A standardized loading indicator component
/// Provides consistent loading states across the app
///
/// Example:
/// ```dart
/// // Center loading
/// LoadingIndicator()
///
/// // Loading with message
/// LoadingIndicator(message: 'Loading data...')
///
/// // Inline loading
/// LoadingIndicator.inline()
/// ```
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size,
    this.color,
  });

  /// Small inline loading indicator
  factory LoadingIndicator.inline({Color? color}) {
    return LoadingIndicator(
      size: 20,
      color: color,
    );
  }

  /// Loading indicator for buttons (use with theme context)
  factory LoadingIndicator.button({Color? color}) {
    return LoadingIndicator(
      size: 20,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox(
      width: size ?? 40,
      height: size ?? 40,
      child: CircularProgressIndicator(
        strokeWidth: (size ?? 40) / 10,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );

    if (message == null) {
      return Center(child: indicator);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(height: AppSizes.paddingMedium),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Overlay loading indicator that covers the entire screen
class OverlayLoadingIndicator extends StatelessWidget {
  final String? message;
  final bool dismissible;

  const OverlayLoadingIndicator({
    super.key,
    this.message,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: dismissible,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(AppSizes.paddingLarge),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    const SizedBox(height: AppSizes.paddingMedium),
                    Text(
                      message!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Show an overlay loading indicator
  static Future<T?> show<T>({
    required BuildContext context,
    required Future<T> Function() task,
    String? message,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OverlayLoadingIndicator(message: message),
    );

    try {
      final result = await task();
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      return result;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      rethrow;
    }
  }
}

/// Linear progress indicator for continuous operations
class LinearLoadingIndicator extends StatelessWidget {
  final double? value;
  final Color? color;
  final Color? backgroundColor;

  const LinearLoadingIndicator({
    super.key,
    this.value,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value,
      color: color ?? Theme.of(context).colorScheme.primary,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}

/// Skeleton loader for content placeholders
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
  });

  /// Text line skeleton
  factory SkeletonLoader.text({
    double? width,
    double height = 16,
  }) {
    return SkeletonLoader(
      width: width ?? 200,
      height: height,
      borderRadius: BorderRadius.circular(4),
    );
  }

  /// Card skeleton
  factory SkeletonLoader.card({
    double? width,
    double height = 100,
  }) {
    return SkeletonLoader(
      width: width ?? double.infinity,
      height: height,
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
    );
  }

  /// Circle skeleton (for avatars)
  factory SkeletonLoader.circle({
    double size = 48,
  }) {
    return SkeletonLoader(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.neutral300,
        borderRadius: borderRadius,
      ),
      child: const ShimmerEffect(),
    );
  }
}

/// Shimmer animation effect for skeleton loaders
class ShimmerEffect extends StatefulWidget {
  const ShimmerEffect({super.key});

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.neutral300,
                AppColors.neutral100,
                AppColors.neutral300,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}
