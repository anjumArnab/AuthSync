import 'package:flutter/material.dart';
import '../views/forgot_password_page.dart';
import '../views/create_acc_page.dart';
import '../views/phone_verification_page.dart';
import '../views/profile_page.dart';
import '../services/auth_service.dart';
import '../widgets/gradient_button.dart';
import '../widgets/auth_field.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add form key
  bool _isPasswordVisible = false;
  bool _isLoading = false; // Add loading state

  final AuthService _authService = AuthService(); // Initialize AuthService

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function to handle sign in
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Sign in with AuthService
      final result = await _authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result != null) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Welcome back, ${result.user?.displayName ?? result.user?.email?.split('@')[0] ?? 'User'}!',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
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
          'Sign In',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight -
                    48, // Account for padding
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Email Field
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AuthField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      hintText: 'Enter your email',
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
                      onChanged: (value) {},
                    ),

                    const SizedBox(height: 20),

                    // Password Field
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AuthField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      hintText: '••••••••',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
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
                    ),

                    const SizedBox(height: 16),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7B68EE),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Sign In Button
                    GradientButton(
                      label: _isLoading ? 'Signing In...' : 'Sign In',
                      isEnabled: !_isLoading,
                      onTap: _isLoading ? null : _signIn,
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

                    const SizedBox(height: 32),

                    // Or Divider
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Social Login Buttons
                    _buildSocialButton(
                      icon: Icons.mail,
                      iconColor: const Color(0xFFEA4335),
                      text: 'Continue with Google',
                      onTap: () => print('Google login tapped'),
                    ),

                    const SizedBox(height: 12),

                    _buildSocialButton(
                      icon: Icons.facebook,
                      iconColor: const Color(0xFF1877F2),
                      text: 'Continue with Facebook',
                      onTap: () => print('Facebook login tapped'),
                    ),

                    const SizedBox(height: 12),

                    _buildSocialButton(
                      icon: Icons.phone_android,
                      iconColor: const Color(0xFF10B981),
                      text: 'Continue with Phone',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PhoneVerificationPage(),
                        ),
                      ),
                    ),

                    // Flexible spacer that grows to push content to bottom
                    const Expanded(
                      child: SizedBox(height: 20),
                    ),

                    // Sign Up Link
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                          children: [
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () =>
                                    Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CreateAccountPage(),
                                  ),
                                ),
                                child: const Text(
                                  'Sign Up',
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
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color iconColor,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
