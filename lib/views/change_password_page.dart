import 'package:authsync/widgets/auth_field.dart';
import 'package:authsync/widgets/snack_bar_helper.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isUpdating = false;

  final AuthService _authService = AuthService(); // Initialize AuthService

  // Password validation requirements
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false; // Add special character requirement

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    String password = _newPasswordController.text;
    setState(() {
      _hasMinLength = password.length >= 6; // Firebase minimum is 6
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool get _isPasswordValid => _hasMinLength && _hasUppercase && _hasNumber;

  // Function to handle password change
  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isPasswordValid) {
      /*ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please ensure your password meets all requirements',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );*/
      SnackBarHelper.warning(
          context, 'Please ensure your password meets all requirements');

      return;
    }

    // Check if user is signed in
    if (!_authService.isUserSignedIn()) {
      /*ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please sign in to change your password',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );*/
      SnackBarHelper.error(context, 'Please sign in to change your password');

      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      // Change password using AuthService
      await _authService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        // Show success message
        /*ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Password updated successfully!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );*/
        SnackBarHelper.success(context, 'Password updated successfully!');

        // Navigate back after successful update
        Navigator.pop(context);
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        /* ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );*/
        SnackBarHelper.error(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
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
          onPressed: _isUpdating ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Password',
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
              // Current user info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF7B68EE)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Changing password for: ${_authService.getCurrentUserEmail() ?? 'Current user'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Current Password
              const Text(
                'Current Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              AuthField(
                controller: _currentPasswordController,
                obscureText: !_isCurrentPasswordVisible,
                hintText: '••••••••',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isCurrentPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  if (value.length < 6) {
                    return 'Current password is too short';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // New Password
              const Text(
                'New Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              AuthField(
                controller: _newPasswordController,
                obscureText: !_isNewPasswordVisible,
                hintText: '••••••••',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isNewPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value == _currentPasswordController.text) {
                    return 'New password must be different from current password';
                  }
                  if (!_isPasswordValid) {
                    return 'Password does not meet requirements';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Confirm New Password
              const Text(
                'Confirm New Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              AuthField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                hintText: '••••••••',
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
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Password Requirements
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Password must contain:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRequirement(
                      'At least 6 characters',
                      _hasMinLength,
                    ),
                    const SizedBox(height: 8),
                    _buildRequirement(
                      'One uppercase letter',
                      _hasUppercase,
                    ),
                    const SizedBox(height: 8),
                    _buildRequirement(
                      'One number',
                      _hasNumber,
                    ),
                    const SizedBox(height: 8),
                    _buildRequirement(
                      'One special character (recommended)',
                      _hasSpecialChar,
                      isOptional: true,
                    ),
                  ],
                ),
              ),

              // Loading indicator
              if (_isUpdating) ...[
                const SizedBox(height: 24),
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF7B68EE)),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Updating password...',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Update Password Button
              CustomButton(
                label: _isUpdating ? 'Updating Password...' : 'Update Password',
                onPressed: _isUpdating ? null : _updatePassword,
                isLoading: _isUpdating,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet, {bool isOptional = false}) {
    return Row(
      children: [
        Icon(
          isMet
              ? Icons.check_circle
              : (isOptional
                  ? Icons.info_outline
                  : Icons.radio_button_unchecked),
          size: 18,
          color: isMet
              ? Colors.green
              : (isOptional ? Colors.blue : Colors.grey.shade400),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isMet
                  ? Colors.green
                  : (isOptional ? Colors.blue : Colors.grey.shade600),
              fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
