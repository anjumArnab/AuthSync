// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../views/accounts_page.dart';
import '../views/change_password_page.dart';
import '../views/update_email_page.dart';
import '../views/delete_account_page.dart';
import '../views/email_verification_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();

  // State variables for user data
  String _userName = "";
  String _userEmail = "";
  String _userInitials = "US";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final email = _authService.getCurrentUserEmail();
      final displayName = _authService.getCurrentUserDisplayName();

      setState(() {
        _userEmail = email ?? "";
        _userName = _getUserNameFromEmail(email, displayName);
        _userInitials = _getUserInitialsFromEmail(email);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _userName = "User";
        _userEmail = "";
        _userInitials = "US";
        _isLoading = false;
      });
    }
  }

  String _getUserNameFromEmail(String? email, String? displayName) {
    // If display name is available, use it
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    // Otherwise, process the email
    if (email != null && email.contains('@')) {
      // Get the part before @ and capitalize first letter of each word
      final localPart = email.split('@')[0];
      // Replace dots, underscores, dashes with spaces and capitalize
      return localPart
          .replaceAll(RegExp(r'[._-]'), ' ')
          .split(' ')
          .map((word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '')
          .join(' ');
    }
    return "User";
  }

  String _getUserInitialsFromEmail(String? email) {
    if (email != null && email.length >= 2) {
      return email.substring(0, 2).toUpperCase();
    }
    return "US"; // Default initials
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _signOut();
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed out successfully')),
        );
        // Navigate to login screen or handle navigation as needed
        // Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign out failed: ${e.toString()}')),
        );
      }
    }
  }

  void _navigateToUpdateEmail() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UpdateEmailPage(),
      ),
    );

    // Refresh user data if email was updated
    if (result == true) {
      _loadUserData();
    }
  }

  void _navigateToChangePassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ChangePasswordPage(),
      ),
    );
  }

  void _navigateToEmailVerification() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EmailVerificationPage(),
      ),
    );
  }

  void _navigateToMultipleAccounts() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AccountsPage(),
      ),
    );

    // If account was switched, refresh the profile page
    if (result == true) {
      _loadUserData();
    }
  }

  void _navigateToDeleteAccount() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DeleteAccountPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FF),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6B73FF),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        40, // Account for padding
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Header with title (centered)
                        const Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Profile Avatar
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B73FF),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6B73FF).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _userInitials,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // User Name
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // User Email
                        Text(
                          _userEmail,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Menu Items Container
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildMenuItem(
                                icon: Icons.email_outlined,
                                title: 'Update Email',
                                onTap: _navigateToUpdateEmail,
                              ),
                              _buildDivider(),
                              _buildMenuItem(
                                icon: Icons.lock_outline,
                                title: 'Change Password',
                                onTap: _navigateToChangePassword,
                              ),
                              _buildDivider(),
                              _buildMenuItem(
                                icon: Icons.verified_user_outlined,
                                title: 'Email Verification',
                                onTap: _navigateToEmailVerification,
                              ),
                              _buildDivider(),
                              _buildMenuItem(
                                icon: Icons.people_outline,
                                title: 'Multiple Accounts',
                                onTap: _navigateToMultipleAccounts,
                              ),
                              _buildDivider(),
                              _buildMenuItem(
                                icon: Icons.delete_outline,
                                title: 'Delete Account',
                                onTap: _navigateToDeleteAccount,
                                isDestructive: true,
                              ),
                            ],
                          ),
                        ),

                        // Flexible spacer
                        const Expanded(
                          child: SizedBox(height: 30),
                        ),

                        // Sign Out Button
                        GestureDetector(
                          onTap: _showSignOutDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: const Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
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
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isDestructive ? Colors.red : Colors.grey.shade600,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? Colors.red : Colors.black,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 24,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Colors.grey.shade200,
    );
  }
}
