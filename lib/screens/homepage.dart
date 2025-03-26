import 'package:authsync/screens/create_account_page.dart';
import 'package:authsync/screens/forget_password_page.dart';
import 'package:authsync/screens/user_info_form.dart';
import 'package:authsync/services/authentication.dart';
import 'package:authsync/utils/snack_bar.dart';
import 'package:authsync/widgets/custom_button.dart';
import 'package:authsync/widgets/custom_text_field.dart';
import 'package:authsync/widgets/icon_container.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Initialize the auth service
  final FirebaseAuthService _authService = FirebaseAuthService();

  void _navToCreateAccountPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateAccountPage(),
      ),
    );
  }

  void _navToUserInfoForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserInfoForm(),
      ),
    );
  }

  void _navToforgetPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ForgetPasswordPage(),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        // Use the snackbar directly for input validation
        showSnackBar(context, 'Email and password cannot be empty');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final userCredential = await _authService.signInWithEmailAndPassword(
          email: email, password: password, context: context);

      if (userCredential != null && userCredential.user != null) {
        // Force refresh the user info to get the latest verification status
        await userCredential.user!.reload();

        if (userCredential.user!.emailVerified) {
          // Email is already verified, navigate to user info form
          if (mounted) {
            _navToUserInfoForm(context);
          }
        } else {
          // Email is not verified, send verification email
          final emailSent = await _authService.sendEmailVerification(context);

          if (emailSent && mounted) {
            // Show a message that verification email was sent
            showSnackBar(context, 'Please verify your email before continuing');

            // You could still navigate to a verification reminder screen
            // or stay on the current screen
          }
        }
      }
    } catch (e) {
      // This catch block will handle any non-FirebaseAuthException errors
      // that weren't caught in the service
      if (mounted) {
        showSnackBar(context, 'Error: ${e.toString()}');
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
      appBar: AppBar(
        title: const Text('AuthSync'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Welcome Back!',
                style: TextStyle(fontSize: 30),
              ),
            ),
            const SizedBox(height: 15),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Email'),
            ),
            CustomTextField(
                controller: _emailController,
                hintText: 'youremail@mail.com',
                keyboardType: TextInputType.text),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Password'),
            ),
            CustomTextField(
                controller: _passwordController,
                hintText: 'Password',
                obsecureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                keyboardType: TextInputType.text),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _navToforgetPassword(context),
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text('Forget Password?'),
              ),
            ),
            const SizedBox(height: 10),
            CustomButton(
              text: _isLoading ? 'Logging in...' : 'Log in',
              onPressed: _isLoading
                  ? null
                  : () async {
                      await _signIn();
                    },
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconContainer(imagePath: 'assets/google.jpg'),
                  const SizedBox(width: 10),
                  IconContainer(imagePath: 'assets/facebook.jpg'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.blue),
                children: [
                  const TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: Colors.black),
                  ),
                  TextSpan(
                    text: 'Sign Up',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.purple,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _navToCreateAccountPage(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
