// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../widgets/snack_bar_helper.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/auth_field.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final TextEditingController _deleteController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isDeleteButtonEnabled = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final AuthService _authService = AuthService(); // Initialize AuthService

  @override
  void initState() {
    super.initState();
    _deleteController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isDeleteButtonEnabled =
          _deleteController.text.toUpperCase() == 'DELETE' &&
              _passwordController.text.isNotEmpty;
    });
  }

  // Function to handle account deletion
  Future<void> _performAccountDeletion() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Delete account using AuthService
      await _authService.deleteAccount(password: _passwordController.text);

      // Show success message
      if (mounted) {
        SnackBarHelper.success(context, 'Account deleted successfully');
      }

      // Navigate to sign in page or home (remove all previous routes)
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/signin',
          (Route<dynamic> route) => false,
        );
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

  void _cancel() {
    if (!_isLoading) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _deleteController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Delete Account',
          style: TextStyle(
            color: Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
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
                    48, // For padding and app bar
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Warning icon with red background
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning,
                          size: 40,
                          color: Colors.orange,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Warning title
                    const Center(
                      child: Text(
                        'This action cannot be undone',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description text
                    const Text(
                      'Deleting your account will permanently remove all your data and cannot be recovered. You will be immediately signed out and will no longer be able to access your account.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Type DELETE confirmation

                    const SizedBox(height: 8),
                    AuthField(
                      label: "Type DELETE",
                      controller: _deleteController,
                      hintText: "Type DELETE to confirm",
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.toUpperCase() != 'DELETE') {
                          return 'Please type DELETE to confirm';
                        }
                        return null;
                      },
                      onChanged: (value) => _validateForm(),
                    ),

                    const SizedBox(height: 16),

                    // Enter password

                    const SizedBox(height: 8),
                    AuthField(
                      label: "Password",
                      controller: _passwordController,
                      hintText: "Enter your current password",
                      obscureText: !_isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your current password';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),

                    // Flexible spacer that grows to push buttons to bottom
                    const Expanded(
                      child: SizedBox(height: 24),
                    ),

                    // Delete My Account button
                    CustomButton(
                      label: _isLoading
                          ? 'Deleting Account...'
                          : 'Delete My Account',
                      onPressed: () =>
                          _isLoading ? null : _performAccountDeletion(),
                      backgroundColor: Colors.red,
                      isEnabled: _isDeleteButtonEnabled && !_isLoading,
                    ),

                    const SizedBox(height: 16),

                    // Cancel button
                    Center(
                      child: TextButton(
                        onPressed: _isLoading ? null : _cancel,
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: _isLoading
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            fontSize: 14,
                          ),
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
}
