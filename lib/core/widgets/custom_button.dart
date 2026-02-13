import 'package:flutter/material.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';

class CustomAppButton extends StatelessWidget {
  const CustomAppButton({
    super.key,
    this.width = double.infinity,
    this.height = 45.0,
    this.onPressed,
    this.style,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.borderRadius,
    this.isLoading = false,
    required this.child,
  });

  final double width, height;
  final void Function()? onPressed;
  final double? borderRadius;
  final TextStyle? style;
  final Color? backgroundColor,
      foregroundColor,
      disabledForegroundColor,
      disabledBackgroundColor;
  final bool isLoading;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: foregroundColor ?? context.colorScheme.onPrimary,
        backgroundColor: backgroundColor ?? context.colorScheme.primary,
        disabledBackgroundColor:
            disabledBackgroundColor ??
            context.colorScheme.primary.withValues(alpha: 0.5),
        disabledForegroundColor:
            disabledForegroundColor ?? context.colorScheme.onPrimary,
        minimumSize: Size(width, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 10.0),
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 20.0,
              width: 20.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: foregroundColor ?? context.colorScheme.onPrimary,
              ),
            )
          : child,
    );
  }
}
