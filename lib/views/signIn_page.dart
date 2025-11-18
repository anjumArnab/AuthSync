import 'package:flutter/material.dart';
import '../widgets/snack_bar_helper.dart';
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
          SnackBarHelper.success(context,
              'Welcome back, ${result.user?.displayName ?? result.user?.email?.split('@')[0] ?? 'User'}!');
        }

        // Navigate to ProfilePage
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/profile', (Route<dynamic> route) => false);
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

  Future<void> _signInWithGoogle() async {
    try {
      final result = await _authService.signInWithGoogle();
      if (result != null) {
        // Show success message
        if (mounted) {
          SnackBarHelper.success(context,
              'Welcome back, ${result.user?.displayName ?? result.user?.email?.split('@')[0] ?? 'User'}!');
        }

        // Navigate to ProfilePage
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/profile', (Route<dynamic> route) => false);
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        SnackBarHelper.error(context, e.toString());
      }
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      final result = await _authService.signInWithFacebook();
      if (result != null) {
        // Show success message
        if (mounted) {
          SnackBarHelper.success(context,
              'Welcome back, ${result.user?.displayName ?? result.user?.email?.split('@')[0] ?? 'User'}!');
        }

        // Navigate to ProfilePage
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/profile', (Route<dynamic> route) => false);
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        SnackBarHelper.error(context, e.toString());
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
                    AuthField(
                      label: 'Email',
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
                    AuthField(
                      label: 'Password',
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
                          Navigator.pushNamed(context, '/forgot-password');
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
                      onTap: () => _signInWithGoogle(),
                    ),

                    const SizedBox(height: 12),

                    _buildSocialButton(
                      icon: Icons.facebook,
                      iconColor: const Color(0xFF1877F2),
                      text: 'Continue with Facebook',
                      onTap: () => _signInWithFacebook(),
                    ),

                    const SizedBox(height: 12),

                    _buildSocialButton(
                      icon: Icons.phone_android,
                      iconColor: const Color(0xFF10B981),
                      text: 'Continue with Phone',
                      onTap: () => Navigator.of(context)
                          .pushNamed('/phone-verification'),
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
                                onTap: () => Navigator.pushNamed(
                                    context, '/create-account'),
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
