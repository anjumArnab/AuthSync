import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/gradient_button.dart';
import '../widgets/auth_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/snack_bar_helper.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  bool _isEmailValid = false;
  bool _isLoading = false;

  // Validation states for manual validation
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Manual validation methods
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }
    if (!_isValidEmail(value.trim())) {
      return "Please enter a valid email address";
    }
    return null;
  }

  void _onEmailChanged(String value) {
    setState(() {
      _emailError = _validateEmail(value);
      _isEmailValid = _emailError == null && value.isNotEmpty;
    });
  }

  bool _validateCurrentForm() {
    final emailError = _validateEmail(_emailController.text);
    setState(() {
      _emailError = emailError;
    });
    return emailError == null;
  }

  Future<void> _sendPasswordResetEmail() async {
    if (!_validateCurrentForm() || !_isEmailValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      _showResetLinkSentDialog();
    } catch (e) {
      String errorMessage = 'An error occurred. Please try again.';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email address.';
            break;
          case 'invalid-email':
            errorMessage = 'Please enter a valid email address.';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many requests. Please try again later.';
            break;
        }
      }

      SnackBarHelper.error(context, errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Lock Icon with Yellow Background
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFFF59E0B),
                  size: 32,
                ),
              ),

              const SizedBox(height: 32),

              // Description Text
              const Text(
                "Enter your email address and we'll send you a reset link",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Email Field
              AuthField(
                label: "Email",
                controller: _emailController,
                hintText: "Enter your email",
                keyboardType: TextInputType.emailAddress,
                onChanged: _onEmailChanged,
                errorText: _emailError,
              ),

              const SizedBox(height: 32),

              // Send Reset Link Button
              GradientButton(
                label: _isLoading ? 'Sending...' : 'Send Reset Link',
                isEnabled: _isEmailValid && !_isLoading,
                onTap: _isLoading ? null : _sendPasswordResetEmail,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : null,
              ),

              const Spacer(),

              // Back to Sign In Link
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
                child: const Text(
                  'Back to Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7B68EE),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetLinkSentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(32),
                ),
                child:
                    const Icon(Icons.check, color: Color(0xFF10B981), size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Reset Link Sent!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ve sent a password reset link to\n${_emailController.text.trim()}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Click the link in your email to reset your password.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Got it',
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to previous page
                },
              )
            ],
          ),
        );
      },
    );
  }
}
