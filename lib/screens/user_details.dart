import 'package:flutter/material.dart';

class UserInfoPage extends StatelessWidget {
  //final UserModel user;

  const UserInfoPage({
    Key? key,
    //required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit page
              // Navigator.push(context, MaterialPageRoute(builder: (context) => UserInfoForm(user: user)));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                      // user.fullName,
                      'Sakib Anjum Arnab',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      //user.phoneNumber,
                      '+8801818447232',
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
              _buildInfoRow('Full Name', 'user.fullName'),
              _buildInfoRow('Gender', 'user.gender'),
              _buildInfoRow('Date of Birth', 'user.dateOfBirth'),
              _buildInfoRow('Blood Group', 'user.bloodGroup'),
              _buildInfoRow('Preferred Language', 'user.preferredLanguage'),
              const SizedBox(height: 24),

              // Contact Information Section
              _buildSectionHeader('Contact Information'),
              _buildInfoRow('Phone Number', 'user.phoneNumber'),
              _buildInfoRow('Emergency Contact', 'user.emergencyContact'),
              _buildInfoRow('Mailing Address', 'user.mailingAddress'),
              const SizedBox(height: 24),

              // Educational Background Section
              _buildSectionHeader('Educational Background'),
              _buildInfoRow('High School', 'user.highSchool'),
              _buildInfoRow('College', 'user.college'),
              _buildInfoRow(
                  'Undergraduate Institution', 'user.undergradInstitution'),
              const SizedBox(height: 24),
            ],
          ),
        ),
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
