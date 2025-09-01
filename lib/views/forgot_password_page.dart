import 'package:flutter/material.dart';
import '../services/password_reset_manager.dart';
import '../services/app_link_service.dart';
import '../widgets/gradient_button.dart';
import '../widgets/auth_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/snack_bar_helper.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String? resetToken; // Pass token if opened via app link

  const ForgotPasswordPage({super.key, this.resetToken});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isLoading = false;
  bool _isResetMode = false; // true when user came from app link
  String? _verifiedEmail;
  String? _currentResetToken;

  // Validation states for manual validation
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _checkResetMode();
    _setupAppLinkListener();
  }

  void _checkResetMode() async {
    // Check if opened with reset token
    String? token = widget.resetToken;

    // If no token passed, check for initial app link
    token ??= await AppLinkService.instance.getInitialResetToken();

    if (token != null) {
      await _verifyTokenAndEnterResetMode(token);
    }
  }

  void _setupAppLinkListener() {
    // Listen for app links while page is open
    AppLinkService.instance.onResetPasswordLink = (String token) {
      _verifyTokenAndEnterResetMode(token);
    };
  }

  Future<void> _verifyTokenAndEnterResetMode(String token) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await PasswordResetManager.verifyResetToken(token);

      if (result != null && result['success'] == true) {
        setState(() {
          _isResetMode = true;
          _verifiedEmail = result['email'];
          _currentResetToken = token;
          _isLoading = false;
          // Clear any existing errors when switching modes
          _clearValidationErrors();
        });
      } else {
        SnackBarHelper.error(
          context,
          'Invalid or expired reset link',
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      SnackBarHelper.error(
        context,
        'Failed to verify reset link',
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    AppLinkService.instance.onResetPasswordLink = null;
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _clearValidationErrors() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please confirm your password";
    }
    if (value != _passwordController.text) {
      return "Passwords don't match";
    }
    return null;
  }

  void _onEmailChanged(String value) {
    setState(() {
      _emailError = _validateEmail(value);
      _isEmailValid = _emailError == null && value.isNotEmpty;
    });
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordError = _validatePassword(value);
      _confirmPasswordError =
          _validateConfirmPassword(_confirmPasswordController.text);
      _isPasswordValid = _passwordError == null &&
          _confirmPasswordError == null &&
          value.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty;
    });
  }

  void _onConfirmPasswordChanged(String value) {
    setState(() {
      _confirmPasswordError = _validateConfirmPassword(value);
      _isPasswordValid = _passwordError == null &&
          _confirmPasswordError == null &&
          _passwordController.text.isNotEmpty &&
          value.isNotEmpty;
    });
  }

  bool _validateCurrentForm() {
    if (!_isResetMode) {
      // Email mode validation
      final emailError = _validateEmail(_emailController.text);
      setState(() {
        _emailError = emailError;
      });
      return emailError == null;
    } else {
      // Password reset mode validation
      final passwordError = _validatePassword(_passwordController.text);
      final confirmPasswordError =
          _validateConfirmPassword(_confirmPasswordController.text);

      setState(() {
        _passwordError = passwordError;
        _confirmPasswordError = confirmPasswordError;
      });

      return passwordError == null && confirmPasswordError == null;
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    if (!_validateCurrentForm() || !_isEmailValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await PasswordResetManager.sendPasswordResetEmail(
        _emailController.text.trim(),
      );

      if (success) {
        _showResetLinkSentDialog();
      } else {
        SnackBarHelper.error(
          context,
          'Failed to send reset email. Please try again.',
        );
      }
    } catch (e) {
      SnackBarHelper.error(
        context,
        'An error occurred. Please try again.',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    if (!_validateCurrentForm() ||
        !_isPasswordValid ||
        _currentResetToken == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await PasswordResetManager.resetPassword(
        _currentResetToken!,
        _passwordController.text,
      );

      if (success) {
        _showPasswordResetSuccessDialog();
      } else {
        SnackBarHelper.error(
          context,
          'Failed to reset password. Please try again.',
        );
      }
    } catch (e) {
      SnackBarHelper.error(
        context,
        'An error occurred. Please try again.',
      );
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
        title: Text(
          _isResetMode ? 'Reset Password' : 'Forgot Password',
          style: const TextStyle(
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
                child: Icon(
                  _isResetMode ? Icons.lock_reset : Icons.lock_outline,
                  color: const Color(0xFFF59E0B),
                  size: 32,
                ),
              ),

              const SizedBox(height: 32),

              // Description Text
              Text(
                _isResetMode
                    ? "Enter your new password for\n${_verifiedEmail ?? 'your account'}"
                    : "Enter your email address and we'll send you a reset link",
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Fields based on mode
              if (!_isResetMode) ...[
                // Email Mode - Send Reset Link
                AuthField(
                  label: "Email",
                  controller: _emailController,
                  hintText: "Enter your email",
                  keyboardType: TextInputType.emailAddress,
                  onChanged: _onEmailChanged,
                  errorText: _emailError,
                ),
              ] else ...[
                // Reset Mode - Enter New Password
                AuthField(
                  label: "New Password",
                  controller: _passwordController,
                  hintText: "Enter new password",
                  obscureText: true,
                  onChanged: _onPasswordChanged,
                  errorText: _passwordError,
                ),

                const SizedBox(height: 16),

                AuthField(
                  label: "Confirm New Password",
                  controller: _confirmPasswordController,
                  hintText: "Confirm new password",
                  obscureText: true,
                  onChanged: _onConfirmPasswordChanged,
                  errorText: _confirmPasswordError,
                ),
              ],

              const SizedBox(height: 32),

              // Action Button
              GradientButton(
                label: _isLoading
                    ? (_isResetMode ? 'Resetting...' : 'Sending...')
                    : (_isResetMode ? 'Reset Password' : 'Send Reset Link'),
                isEnabled: (_isResetMode ? _isPasswordValid : _isEmailValid) &&
                    !_isLoading,
                onTap: _isLoading
                    ? null
                    : (_isResetMode ? _resetPassword : _sendPasswordResetEmail),
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

  void _showPasswordResetSuccessDialog() {
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
                'Password Reset Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your password has been successfully reset.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'You can now sign in with your new password.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Sign In',
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to sign in
                },
              )
            ],
          ),
        );
      },
    );
  }
}
