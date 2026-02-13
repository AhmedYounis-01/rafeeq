import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../extensions/theme_extension.dart';

enum TextFieldType { email, password, text, number, phone, multiline }

enum TextFieldSize { small, medium, large }

class CustomTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextFieldType type;
  final TextFieldSize size;
  final bool isRequired;
  final bool isEnabled;
  final bool isReadOnly;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final VoidCallback? onSuffixIconPressed;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final bool showPasswordToggle;
  final bool autoFocus;
  final String? initialValue;

  const CustomTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.type = TextFieldType.text,
    this.size = TextFieldSize.medium,
    this.isRequired = false,
    this.isEnabled = true,
    this.isReadOnly = false,
    this.autoFocus = false,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.onSuffixIconPressed,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.textInputAction,
    this.focusNode,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderRadius,
    this.contentPadding,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.showPasswordToggle = true,
    this.initialValue,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isPasswordVisible = false;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get size-specific properties
    final sizeProps = _getSizeProperties();

    // Get type-specific properties
    final typeProps = _getTypeProperties();

    final effectiveFillColor =
        widget.fillColor ?? context.colorScheme.surfaceContainer;
    final effectiveBorderColor =
        widget.borderColor ?? context.colorScheme.outline;
    final effectiveFocusedBorderColor =
        widget.focusedBorderColor ?? context.colorScheme.primary;
    final effectiveErrorBorderColor =
        widget.errorBorderColor ?? context.colorScheme.error;
    final effectiveBorderRadius = widget.borderRadius ?? 12.r;
    final effectiveContentPadding =
        widget.contentPadding ?? sizeProps.contentPadding;

    // Build label with required indicator
    Widget? labelWidget;
    if (widget.labelText != null) {
      labelWidget = RichText(
        text: TextSpan(
          text: widget.labelText!,
          style:
              widget.labelStyle ??
              TextStyle(
                fontSize: sizeProps.labelFontSize,
                fontWeight: FontWeight.w500,
                color: context.colorScheme.onSurface,
              ),
          children: widget.isRequired
              ? [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: context.colorScheme.error,
                      fontSize: sizeProps.labelFontSize,
                    ),
                  ),
                ]
              : null,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelWidget != null) ...[labelWidget, SizedBox(height: 8.h)],

        Theme(
          data: context.theme.copyWith(
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: context.colorScheme.primary,
              selectionColor: context.colorScheme.primary.withValues(
                alpha: 0.4,
              ),
              selectionHandleColor: context.colorScheme.primary,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            initialValue: widget.initialValue,
            focusNode: _focusNode,
            enabled: widget.isEnabled,
            readOnly: widget.isReadOnly,
            autofocus: widget.autoFocus,
            obscureText:
                widget.type == TextFieldType.password &&
                widget.showPasswordToggle &&
                !_isPasswordVisible,
            keyboardType: typeProps.keyboardType,
            textInputAction:
                widget.textInputAction ?? typeProps.textInputAction,
            textCapitalization: widget.textCapitalization,
            maxLines: widget.maxLines ?? typeProps.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            inputFormatters:
                widget.inputFormatters ?? typeProps.inputFormatters,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            style:
                widget.textStyle ??
                TextStyle(
                  fontSize: sizeProps.textFontSize,
                  color: context.colorScheme.onSurface,
                ),
            cursorColor: context.colorScheme.primary,
            selectionControls: MaterialTextSelectionControls(),
            decoration: InputDecoration(
              hintText: widget.hintText,
              helperText: widget.helperText,
              errorText: widget.errorText,
              hintStyle:
                  widget.hintStyle ??
                  TextStyle(
                    fontSize: sizeProps.textFontSize,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
              filled: true,
              fillColor: effectiveFillColor,
              contentPadding: effectiveContentPadding,

              // Prefix
              prefixIcon: widget.prefix != null
                  ? Padding(
                      padding: EdgeInsets.only(left: 0, right: 0),
                      child: widget.prefix,
                    )
                  : (widget.prefixIcon != null
                        ? Icon(
                            widget.prefixIcon,
                            size: sizeProps.iconSize,
                            color: _isFocused
                                ? effectiveFocusedBorderColor
                                : context.colorScheme.onSurfaceVariant,
                          )
                        : null),

              // Suffix
              suffixIcon: _buildSuffixIcon(
                sizeProps,
                effectiveFocusedBorderColor,
              ),
              suffix: widget.suffix,

              // Borders
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(effectiveBorderRadius),
                borderSide: BorderSide(color: effectiveBorderColor, width: 1.w),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(effectiveBorderRadius),
                borderSide: BorderSide(color: effectiveBorderColor, width: 1.w),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(effectiveBorderRadius),
                borderSide: BorderSide(
                  color: effectiveFocusedBorderColor,
                  width: 2.w,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(effectiveBorderRadius),
                borderSide: BorderSide(
                  color: effectiveErrorBorderColor,
                  width: 1.w,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(effectiveBorderRadius),
                borderSide: BorderSide(
                  color: effectiveErrorBorderColor,
                  width: 2.w,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(effectiveBorderRadius),
                borderSide: BorderSide(
                  color: context.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                  width: 1.w,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon(_SizeProperties sizeProps, Color focusedColor) {
    // Password visibility toggle
    if (widget.type == TextFieldType.password && widget.showPasswordToggle) {
      return IconButton(
        icon: Icon(
          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          size: sizeProps.iconSize,
          color: _isFocused
              ? focusedColor
              : context.colorScheme.onSurfaceVariant,
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
          widget.onSuffixIconPressed?.call();
        },
      );
    }

    // Custom suffix icon
    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          size: sizeProps.iconSize,
          color: _isFocused
              ? focusedColor
              : context.colorScheme.onSurfaceVariant,
        ),
        onPressed: widget.onSuffixIconPressed,
      );
    }

    return null;
  }

  _SizeProperties _getSizeProperties() {
    switch (widget.size) {
      case TextFieldSize.small:
        return _SizeProperties(
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          textFontSize: 14.sp,
          labelFontSize: 12.sp,
          iconSize: 18.w,
        );
      case TextFieldSize.medium:
        return _SizeProperties(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          textFontSize: 16.sp,
          labelFontSize: 14.sp,
          iconSize: 20.w,
        );
      case TextFieldSize.large:
        return _SizeProperties(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 16.h,
          ),
          textFontSize: 18.sp,
          labelFontSize: 16.sp,
          iconSize: 24.w,
        );
    }
  }

  _TypeProperties _getTypeProperties() {
    switch (widget.type) {
      case TextFieldType.email:
        return _TypeProperties(
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          maxLines: 1,
          inputFormatters: null,
        );
      case TextFieldType.password:
        return _TypeProperties(
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          maxLines: 1,
          inputFormatters: null,
        );
      case TextFieldType.number:
        return _TypeProperties(
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          maxLines: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        );
      case TextFieldType.phone:
        return _TypeProperties(
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          maxLines: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        );
      case TextFieldType.multiline:
        return _TypeProperties(
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          maxLines: null,
          inputFormatters: null,
        );
      case TextFieldType.text:
        return _TypeProperties(
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          maxLines: 1,
          inputFormatters: null,
        );
    }
  }
}

class _SizeProperties {
  final EdgeInsetsGeometry contentPadding;
  final double textFontSize;
  final double labelFontSize;
  final double iconSize;

  _SizeProperties({
    required this.contentPadding,
    required this.textFontSize,
    required this.labelFontSize,
    required this.iconSize,
  });
}

class _TypeProperties {
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;

  _TypeProperties({
    required this.keyboardType,
    required this.textInputAction,
    required this.maxLines,
    required this.inputFormatters,
  });
}
