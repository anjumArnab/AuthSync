import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/gradient_button.dart';
import '../widgets/auth_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add form key
  bool _isEmailValid = false;
  bool _isLoading = false; // Add loading state

  final AuthService _authService = AuthService(); // Initialize AuthService

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _onEmailChanged(String value) {
    setState(() {
      _isEmailValid = value.isNotEmpty && _isValidEmail(value);
    });
  }

  // Function to handle forgot password
  Future<void> _sendPasswordResetEmail() async {
    if (!_formKey.currentState!.validate() || !_isEmailValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      // Show success dialog
      if (mounted) {
        _showResetLinkSentDialog();
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
        child: Form(
          // Wrap with Form widget
          key: _formKey,
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

                // Email Address Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AuthField(
                      label: "Email",
                      controller: _emailController,
                      hintText: "Enter your email",
                      keyboardType: TextInputType.emailAddress,
                      onChanged: _onEmailChanged,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email is required";
                        }
                        if (!_isValidEmail(value.trim())) {
                          return "Please enter a valid email address";
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Send Reset Link Button
                GradientButton(
                  label: _isLoading ? 'Sending...' : 'Send Reset Link',
                  isEnabled: _isEmailValid && !_isLoading,
                  onTap: _isLoading ? null : _sendPasswordResetEmail,
                ),

                // Loading indicator
                if (_isLoading) ...[
                  const SizedBox(height: 16),
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF7B68EE)),
                    ),
                  ),
                ],

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
      ),
    );
  }

  void _showResetLinkSentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF10B981),
                  size: 32,
                ),
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
                'Please check your email and follow the instructions to reset your password.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to previous page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B68EE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
