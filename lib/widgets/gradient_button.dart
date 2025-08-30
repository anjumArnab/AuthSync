import 'package:flutter/material.dart';

class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isEnabled;
  final Widget? child;

  const GradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.isEnabled = true,
    this.child,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isEnabled ? widget.onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          gradient: widget.isEnabled
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _isPressed
                      ? [
                          const Color(0xFF6A5ACD),
                          const Color(0xFF5B4BC4),
                        ]
                      : [
                          const Color(0xFF7B68EE),
                          const Color(0xFF6A5ACD),
                        ],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE5E7EB),
                    Color(0xFFD1D5DB),
                  ],
                ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: widget.isEnabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF7B68EE).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: widget.child ??
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      widget.isEnabled ? Colors.white : const Color(0xFF9CA3AF),
                ),
              ),
        ),
      ),
    );
  }
}
