import 'package:flutter/material.dart';
import '../widgets/snack_bar_helper.dart';
import '../widgets/custom_button.dart';
import '../widgets/auth_field.dart';
import '../services/auth_service.dart';

class UpdateEmailPage extends StatefulWidget {
  const UpdateEmailPage({super.key});

  @override
  State<UpdateEmailPage> createState() => _UpdateEmailPageState();
}

class _UpdateEmailPageState extends State<UpdateEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _newEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  String? currentEmail;
  bool _passwordVisible = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    // Get current user's email
    currentEmail = _authService.getCurrentUserEmail();
  }

  @override
  void dispose() {
    _newEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _updateEmail() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if new email is different from current email
    if (_newEmailController.text.trim().toLowerCase() ==
        (currentEmail?.toLowerCase() ?? '')) {
      /* _showSnackBar(
        'New email must be different from current email',
        Colors.orange,
      );*/
      SnackBarHelper.warning(
          context, 'New email must be different from current email');
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      // Call Firebase Auth service to update email
      await _authService.updateEmail(
        newEmail: _newEmailController.text.trim(),
        password: _passwordController.text,
      );

      // Send email verification to the new email
      await _authService.sendEmailVerification();

      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });

        // Show error message
        SnackBarHelper.error(context, e.toString());
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('Email Update Requested'),
            ],
          ),
          content: Text(
            'We\'ve sent a verification link to ${_newEmailController.text}. '
            'Please check your inbox and click the verification link to complete the email update. '
            'You may need to sign in again after verification.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous page
              },
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Update Email',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Email
              const Text(
                'Current Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  currentEmail ?? 'No email found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // New Email
              AuthField(
                controller: _newEmailController,
                label: "New Email",
                hintText: "Enter your new email address",
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a new email address';
                  }
                  if (!_isValidEmail(value.trim())) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Confirm Password
              AuthField(
                controller: _passwordController,
                label: "Password",
                hintText: "Enter your current password",
                obscureText: !_passwordVisible,
                keyboardType: TextInputType.visiblePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password to confirm';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Information Banner

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'We\'ll send a verification link to your new email address.\n You may need to sign in again after verification.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Update Email Button
              CustomButton(
                label: 'Update Email',
                onPressed: _updateEmail,
                isLoading: _isUpdating,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
