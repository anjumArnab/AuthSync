import 'package:flutter/material.dart';
import '../widgets/snack_bar_helper.dart';
import 'signin_page.dart';
import 'profile_page.dart';
import '../services/auth_service.dart';
import '../widgets/gradient_button.dart';
import '../widgets/auth_field.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _isLoading = false; // Add loading state

  final AuthService _authService = AuthService(); // Initialize AuthService

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _fullNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text &&
        _passwordController.text.length >=
            6 && // Add password length validation
        _agreeToTerms;
  }

  // Function to handle account creation
  Future<void> _createAccount() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create account with AuthService
      final result = await _authService.createAccount(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _fullNameController.text.trim(),
      );

      if (result != null) {
        // Send email verification
        try {
          await _authService.sendEmailVerification();
        } catch (e) {
          // Email verification failed, but account was created
          print('Email verification failed: $e');
        }

        // Show success message
        if (mounted) {
          SnackBarHelper.success(
            context,
            "Account created successfully! Please check your email for verification.",
          );
        }

        // Navigate to ProfilePage
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ProfilePage(),
            ),
          );
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        SnackBarHelper.error(context, e.toString());
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
          'Create Account',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Full Name Field
              AuthField(
                label: 'Full Name',
                controller: _fullNameController,
                hintText: 'Enter your full name',
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Email Field
              AuthField(
                label: 'Email',
                controller: _emailController,
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Password Field
              AuthField(
                label: "Password",
                controller: _passwordController,
                hintText: "••••••••",
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter password";
                  }
                  if (value.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Confirm Password Field
              AuthField(
                label: "Confirm Password",
                controller: _confirmPasswordController,
                hintText: "••••••••",
                obscureText: !_isConfirmPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please confirm your password";
                  }
                  if (value != _passwordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Terms and Privacy Policy Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreeToTerms,
                      onChanged: (bool? value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF7B68EE),
                      checkColor: Colors.white,
                      side: const BorderSide(
                        color: Color(0xFFE5E7EB),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: 'I agree to the ',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => print('Terms tapped'),
                              child: const Text(
                                'Terms',
                                style: TextStyle(
                                  color: Color(0xFF7B68EE),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => print('Privacy Policy tapped'),
                              child: const Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  color: Color(0xFF7B68EE),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Create Account Button
              GradientButton(
                label: 'Create Account',
                isEnabled: _isFormValid && !_isLoading,
                onTap: _isLoading ? null : _createAccount,
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

              const SizedBox(height: 32),

              // Sign In Link
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const SignInPage())),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Color(0xFF7B68EE),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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
}
