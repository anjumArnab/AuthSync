import 'package:authsync/services/authentication.dart';
import 'package:authsync/utils/snack_bar.dart';
import 'package:authsync/widgets/custom_button.dart';
import 'package:authsync/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();  
 bool _isLoading = false;
  bool _isPasswordVisible = false;

  // Initialize the auth service
  final FirebaseAuthService _authService = FirebaseAuthService();

 Future<void> _changePassword() async {
    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      showSnackBar(context, 'Please fill in both fields.');
      return;
    }
    if (newPassword != confirmPassword) {
      showSnackBar(context, 'Passwords do not match.');
      return;
    }
    if (newPassword.length < 6) {
      showSnackBar(context, 'Password must be at least 6 characters long.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool success = await _authService.changePassword(newPassword, context);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pop(context); // Navigate back on success
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("AuthSync"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Reset Password',
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('New Password'),
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
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Confirm Password'),
                ),
                CustomTextField(
                    controller: _confirmPasswordController,
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
                  text: _isLoading ? 'Resetting...' : 'Reset',
                  onPressed: _isLoading
                      ? null
                      : () async {
                          await _changePassword();
                        },
                ),
              ],
            )));
  }
}
