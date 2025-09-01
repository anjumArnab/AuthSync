import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool filled;
  final bool? enabled;
  final Color fillColor;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry contentPadding;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? errorText;

  const AuthField({
    super.key,
    this.label,
    this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.filled = true,
    this.enabled,
    this.fillColor = const Color(0xFFF9FAFB),
    this.suffixIcon,
    this.inputFormatters,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    this.validator,
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          validator: validator,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 16,
            ),
            filled: filled,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF7B68EE), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            suffixIcon: suffixIcon,
            contentPadding: contentPadding,
            errorText: errorText, // Use errorText for manual error display
            errorStyle: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            errorMaxLines: 2, // Allow multi-line error messages
          ),
        ),
      ],
    );
  }
}
