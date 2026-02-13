import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../extensions/theme_extension.dart';
import '../themes/app_colors.dart';

enum ToastType { success, error, warning, info }

class CustomToast extends StatelessWidget {
  final String title;
  final String message;
  final ToastType type;
  final Widget? action;

  const CustomToast({
    super.key,
    required this.title,
    required this.message,
    this.type = ToastType.success,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.toastBgPrimary,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: isRtl ? null : -40.w,
            right: isRtl ? -40.w : null,
            top: -40.h,
            child: Container(
              width: 150.w,
              height: 150.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _getToastColor(context).withValues(alpha: 0.15),
                    _getToastColor(context).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getToastColor(context).withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getToastColor(context),
                      ),
                      child: Icon(
                        _getIcon(),
                        color: AppColors.white,
                        size: 16.w,
                        weight: 800,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textStyle.displaySmall?.copyWith(
                          color: AppColors.toastTextPrimary,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        message,
                        style: context.textStyle.bodyMedium?.copyWith(
                          color: AppColors.toastTextSecondary,
                          fontSize: 14.sp,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                if (action != null) ...[SizedBox(width: 8.w), action!],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getToastColor(BuildContext context) {
    switch (type) {
      case ToastType.success:
        return context.statusColors.success;
      case ToastType.error:
        return context.statusColors.error;
      case ToastType.warning:
        return context.statusColors.warning;
      case ToastType.info:
        return context.statusColors.info;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case ToastType.success:
        return Icons.check_rounded;
      case ToastType.error:
        return Icons.close_rounded;
      case ToastType.warning:
        return Icons.priority_high_rounded;
      case ToastType.info:
        return Icons.info_outline_rounded;
    }
  }
}

class ToastUtils {
  static void Function()? _currentDismiss;

  static void show({
    required BuildContext context,
    required String title,
    required String message,
    ToastType type = ToastType.success,
    Duration duration = const Duration(seconds: 4),
    Widget? action,
  }) {
    // Dismiss any existing toast before showing a new one
    _currentDismiss?.call();

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    bool isRemoved = false;

    void safeRemove() {
      if (!isRemoved) {
        isRemoved = true;
        overlayEntry.remove();
        // Clear the reference if this was the current toast
        if (_currentDismiss == safeRemove) {
          _currentDismiss = null;
        }
      }
    }

    // Store the dismiss function for the new toast
    _currentDismiss = safeRemove;

    final animationKey = GlobalKey<_ToastAnimationState>();

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20.h,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: _ToastAnimation(
            key: animationKey,
            duration: duration,
            onDismiss: safeRemove,
            child: Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.horizontal,
              onDismissed: (_) => safeRemove(),
              child: GestureDetector(
                onTap: () {
                  animationKey.currentState?.reverseAndDismiss();
                },
                child: CustomToast(
                  title: title,
                  message: message,
                  type: type,
                  action: action,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class _ToastAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastAnimation({
    super.key,
    required this.child,
    required this.duration,
    required this.onDismiss,
  });

  @override
  _ToastAnimationState createState() => _ToastAnimationState();
}

class _ToastAnimationState extends State<_ToastAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _offsetAnimation =
        Tween<Offset>(begin: const Offset(0, -1.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutQuart,
            reverseCurve: Curves.easeInQuart,
          ),
        );

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Auto dismiss
    Future.delayed(widget.duration - const Duration(milliseconds: 800), () {
      if (mounted && !_isDismissing) {
        reverseAndDismiss();
      }
    });
  }

  void reverseAndDismiss() {
    if (_isDismissing) return;
    _isDismissing = true;
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(opacity: _opacityAnimation, child: widget.child),
    );
  }
}
