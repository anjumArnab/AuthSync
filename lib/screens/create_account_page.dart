import 'package:authsync/screens/homepage.dart';
import 'package:authsync/services/authentication.dart';
import 'package:authsync/widgets/custom_button.dart';
import 'package:authsync/widgets/custom_text_field.dart';
import 'package:authsync/widgets/icon_container.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Initialize the auth service
  final FirebaseAuthService _authService = FirebaseAuthService();

  void _navToHomePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  // Function to handle sign up
  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        // Use the snackbar directly for input validation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email and password cannot be empty')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Create user with Firebase Auth - service now handles snackbar display
      final userCredential = await _authService.createUser(
        email: email,
        password: password,
        context: context,
      );

      if (userCredential != null) {
        // Send email verification - service now handles snackbar display
        final emailSent = await _authService.sendEmailVerification(context);

        if (emailSent && mounted) {
          _navToHomePage(context);
        }
      }
    } catch (e) {
      // This catch block will handle any non-FirebaseAuthException errors
      // that weren't caught in the service
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
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
                'Create an Account',
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
                keyboardType: TextInputType.emailAddress),
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
            CustomButton(
              text: _isLoading ? 'Creating Account...' : 'Sign Up',
              onPressed: _isLoading
                  ? null
                  : () async {
                      await _signUp();
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
                    text: "Already have an account? ",
                    style: TextStyle(color: Colors.black),
                  ),
                  TextSpan(
                    text: 'Log in',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.purple,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _navToHomePage(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
