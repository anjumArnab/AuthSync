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
  UserModel? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService(uid: _authService.currentUser!.uid);
    _loadUserData();
  }

  void _loadUserData() async {
    UserModel? userData = await _databaseService.getUserData();
    if (mounted) {
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    }
  }

  void _navToHomePage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void _navToUserInfo(BuildContext context) {
    if (_userData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserInfoForm(userData: _userData!),
        ),
      ).then((_) => _loadUserData()); // Reload user data after returning
    }
  }

  void _navToResetPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
    );
  }

  void _navToChangeEmail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangeEmailPage()),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(child: Text("No user data available."))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              _userData!.fullName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _userData!.phoneNumber,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                      _buildSectionHeader('Personal Information'),
                      _buildInfoRow('Full Name', _userData!.fullName),
                      _buildInfoRow('Gender', _userData!.gender),
                      _buildInfoRow('Date of Birth', _userData!.dateOfBirth),
                      _buildInfoRow('Blood Group', _userData!.bloodGroup),
                      _buildInfoRow('Preferred Language', _userData!.preferredLanguage),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Contact Information'),
                      _buildInfoRow('Phone Number', _userData!.phoneNumber),
                      _buildInfoRow('Emergency Contact', _userData!.emergencyContact),
                      _buildInfoRow('Mailing Address', _userData!.mailingAddress),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Educational Background'),
                      _buildInfoRow('High School', _userData!.highSchool),
                      _buildInfoRow('College', _userData!.college),
                      _buildInfoRow('Undergraduate Institution', _userData!.undergradInstitution),
                      const SizedBox(height: 24),
                      CustomButton(text: "Change Email", onPressed: () => _navToChangeEmail(context)),
                      const SizedBox(height: 15),
                      CustomButton(text: "Change Password", onPressed: () => _navToResetPassword(context)),
                      const SizedBox(height: 15),
                      CustomButton(text: "Delete Account", onPressed: () => _deleteAccount()),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const Divider(thickness: 1),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? 'Not provided' : value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
