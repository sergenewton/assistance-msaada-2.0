import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? theme.primaryColor;
    final effectiveTextColor = textColor ?? Colors.white;
    final effectivePadding = padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 24);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(8);

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isDisabled || isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveTextColor,
          padding: effectivePadding,
          shape: RoundedRectangleBorder(
            borderRadius: effectiveBorderRadius,
          ),
          elevation: 2,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: effectiveTextColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Variant for outline button
class CustomOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? borderColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const CustomOutlineButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.borderColor,
    this.textColor,
    this.width,
    this.height,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderColor = borderColor ?? theme.primaryColor;
    final effectiveTextColor = textColor ?? theme.primaryColor;
    final effectivePadding = padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 24);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(8);

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: OutlinedButton(
        onPressed: isDisabled || isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveTextColor,
          padding: effectivePadding,
          side: BorderSide(color: effectiveBorderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: effectiveBorderRadius,
          ),
          disabledForegroundColor: Colors.grey.shade600,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: effectiveTextColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Variant for text button
class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? textColor;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  const CustomTextButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.textColor,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTextColor = textColor ?? theme.primaryColor;
    final effectivePadding = padding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 16);

    return TextButton(
      onPressed: isDisabled || isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: effectiveTextColor,
        padding: effectivePadding,
        disabledForegroundColor: Colors.grey.shade600,
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: effectiveTextColor,
                  ),
                ),
              ],
            ),
    );
  }
}