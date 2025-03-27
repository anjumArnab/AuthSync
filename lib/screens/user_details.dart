import 'package:authsync/models/user.dart';
import 'package:authsync/screens/change_email_page.dart';
import 'package:authsync/screens/homepage.dart';
import 'package:authsync/screens/reset_password_page.dart';
import 'package:authsync/screens/user_info_form.dart';
import 'package:authsync/services/authentication.dart';
import 'package:authsync/services/database.dart';
import 'package:authsync/utils/snack_bar.dart';
import 'package:authsync/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  late DatabaseService _databaseService;
  late Future<UserModel?> _userData;

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService(uid: _authService.currentUser!.uid);
    _userData = _databaseService.getUserData();
  }

  void _navToHomePage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  void _navToUserInfo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserInfoForm(),
      ),
    );
  }

  void _navToResetPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ResetPasswordPage(),
      ),
    );
  }

  void _navToChangeEmail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChangeEmailPage(),
      ),
    );
  }

  void _deleteAccount() async {
    bool success = await _authService.deleteUser(context);
    if (success) {
      showSnackBar(context, 'Account deleted successfully.');
      _navToHomePage(context);
    } else {
      showSnackBar(context, 'Failed to delete account. Please try again.');
    }
  }

  void _logout() async {
    bool success = await _authService.signOut(context);

    if (success) {
      showSnackBar(context, 'Successfully logged out.');
      if (mounted) {
        _navToHomePage(context);
      }
    } else {
      showSnackBar(context, 'Logout failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navToUserInfo(context),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => _logout(),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: FutureBuilder<UserModel?>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No user data available."));
          }

          final user = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Header
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xFF1976D2),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.phoneNumber,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // Personal Information Section
                  _buildSectionHeader('Personal Information'),
                  _buildInfoRow('Full Name', user.fullName),
                  _buildInfoRow('Gender', user.gender),
                  _buildInfoRow('Date of Birth', user.dateOfBirth),
                  _buildInfoRow('Blood Group', user.bloodGroup),
                  _buildInfoRow('Preferred Language', user.preferredLanguage),
                  const SizedBox(height: 24),

                  // Contact Information Section
                  _buildSectionHeader('Contact Information'),
                  _buildInfoRow('Phone Number', user.phoneNumber),
                  _buildInfoRow('Emergency Contact', user.emergencyContact),
                  _buildInfoRow('Mailing Address', user.mailingAddress),
                  const SizedBox(height: 24),

                  // Educational Background Section
                  _buildSectionHeader('Educational Background'),
                  _buildInfoRow('High School', user.highSchool),
                  _buildInfoRow('College', user.college),
                  _buildInfoRow('Undergraduate Institution', user.undergradInstitution),
                  const SizedBox(height: 24),

                  // Change Email and Password
                  CustomButton(
                      text: "Change Email",
                      onPressed: () => _navToChangeEmail(context)),
                  const SizedBox(height: 15),
                  CustomButton(
                      text: "Change Password",
                      onPressed: () => _navToResetPassword(context)),
                  const SizedBox(height: 15),
                  CustomButton(
                      text: "Delete Account", onPressed: () => _deleteAccount()),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method to build section headers
  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Divider(thickness: 1),
        const SizedBox(height: 8),
      ],
    );
  }

  // Helper method to build info rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? 'Not provided' : value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
