import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final String? errorText;
  final String? helperText;
  final bool showCounter;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    Key? key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.contentPadding,
    this.errorText,
    this.helperText,
    this.showCounter = false,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  late TextEditingController _controller;
  bool _isControllerInternal = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController(text: widget.initialValue);
      _isControllerInternal = true;
    }
  }

  @override
  void dispose() {
    if (_isControllerInternal) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: _controller,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          focusNode: widget.focusNode,
          textCapitalization: widget.textCapitalization,
          style: TextStyle(
            fontSize: 16,
            color: widget.enabled 
                ? theme.colorScheme.onSurface 
                : theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 16,
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon(),
            contentPadding: widget.contentPadding ?? 
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
            ),
            errorText: widget.errorText,
            helperText: widget.helperText,
            counterText: widget.showCounter ? null : '',
            filled: !widget.enabled,
            fillColor: widget.enabled ? null : theme.colorScheme.surface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }
}

// Specialized text field for search
class SearchTextField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final FocusNode? focusNode;

  const SearchTextField({
    Key? key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hint: hint ?? 'Rechercher...',
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: controller != null && controller!.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller!.clear();
                onClear?.call();
              },
            )
          : null,
      textInputAction: TextInputAction.search,
    );
  }
}

// Specialized text field for multiline input
class MultilineTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? maxLength;
  final bool showCounter;

  const MultilineTextField({
    Key? key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.validator,
    this.maxLines = 5,
    this.maxLength,
    this.showCounter = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      hint: hint,
      initialValue: initialValue,
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      maxLines: maxLines,
      minLines: 3,
      maxLength: maxLength,
      showCounter: showCounter,
      textInputAction: TextInputAction.newline,
      keyboardType: TextInputType.multiline,
    );
  }
}