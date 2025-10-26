import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;
  final bool showMessage;

  const LoadingIndicator({
    Key? key,
    this.message,
    this.color,
    this.size = 24.0,
    this.showMessage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).primaryColor,
              ),
            ),
          ),
          if (showMessage && message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isVisible;
  final Widget child;

  const LoadingOverlay({
    Key? key,
    this.message,
    required this.isVisible,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isVisible)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: LoadingIndicator(
              message: message ?? 'Chargement...',
              color: Colors.white,
              size: 40,
            ),
          ),
      ],
    );
  }
}

// Linear loading indicator
class LinearLoadingIndicator extends StatelessWidget {
  final Color? backgroundColor;
  final Color? valueColor;
  final double? value;
  final double height;

  const LinearLoadingIndicator({
    Key? key,
    this.backgroundColor,
    this.valueColor,
    this.value,
    this.height = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LinearProgressIndicator(
        backgroundColor: backgroundColor ?? Colors.grey.shade200,
        valueColor: AlwaysStoppedAnimation<Color>(
          valueColor ?? Theme.of(context).primaryColor,
        ),
        value: value,
      ),
    );
  }
}

// Shimmer loading effect for list items
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    Key? key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? Colors.grey.shade300;
    final highlightColor = widget.highlightColor ?? Colors.grey.shade100;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

// Skeleton loader for common UI patterns
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }
}

// List item skeleton
class ListItemSkeleton extends StatelessWidget {
  final bool showAvatar;
  final bool showTrailing;

  const ListItemSkeleton({
    Key? key,
    this.showAvatar = true,
    this.showTrailing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (showAvatar) ...[
            const SkeletonLoader(
              width: 48,
              height: 48,
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                SkeletonLoader(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 14,
                ),
              ],
            ),
          ),
          if (showTrailing) ...[
            const SizedBox(width: 16),
            const SkeletonLoader(width: 48, height: 32),
          ],
        ],
      ),
    );
  }
}

// Card skeleton
class CardSkeleton extends StatelessWidget {
  final double? height;

  const CardSkeleton({Key? key, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonLoader(width: double.infinity, height: 20),
            const SizedBox(height: 12),
            const SkeletonLoader(width: double.infinity, height: 16),
            const SizedBox(height: 8),
            SkeletonLoader(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 16,
            ),
            if (height != null) ...[
              const SizedBox(height: 16),
              SkeletonLoader(
                width: double.infinity,
                height: height! - 100,
              ),
            ],
          ],
        ),
      ),
    );
  }
}