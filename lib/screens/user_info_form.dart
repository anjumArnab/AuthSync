import 'package:authsync/screens/homepage.dart';
import 'package:authsync/services/authentication.dart';
import 'package:authsync/utils/snack_bar.dart';
import 'package:authsync/widgets/custom_button.dart';
import 'package:authsync/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class UserInfoForm extends StatefulWidget {
  const UserInfoForm({super.key});

  @override
  State<UserInfoForm> createState() => _UserInfoFormState();
}

class _UserInfoFormState extends State<UserInfoForm> {
  final TextEditingController _fullname = TextEditingController();
  final TextEditingController _gender = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  final TextEditingController _bloodGroup = TextEditingController();
  final TextEditingController _language = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _emergencyContact = TextEditingController();
  final TextEditingController _mailingAddress = TextEditingController();
  final TextEditingController _highSchool = TextEditingController();
  final TextEditingController _college = TextEditingController();
  final TextEditingController _undergradInstitution = TextEditingController();

  // Initialize the auth service
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void dispose() {
    _fullname.dispose();
    _gender.dispose();
    _dob.dispose();
    _bloodGroup.dispose();
    _language.dispose();
    _phone.dispose();
    _emergencyContact.dispose();
    _mailingAddress.dispose();
    _highSchool.dispose();
    _college.dispose();
    _undergradInstitution.dispose();
    super.dispose();
  }

  void _navToHomePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
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
        title: const Text('AuthSync'),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout_outlined),
              onPressed: () => _logout()),
          const SizedBox(width: 15),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please enter your information',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              Text('for ${_authService.currentUser!.email}'),
              const SizedBox(height: 20),
              // Personal Information Section
              const Text(
                'Personal Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const Divider(),
              const SizedBox(height: 10),

              const Text('Full Name'),
              CustomTextField(
                controller: _fullname,
                hintText: 'Enter your full name',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 15),

              const Text('Gender'),
              CustomTextField(
                controller: _gender,
                hintText: 'Enter your gender',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 15),

              const Text('Date of Birth'),
              CustomTextField(
                controller: _dob,
                hintText: 'DD/MM/YYYY',
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 15),

              const Text('Blood Group'),
              CustomTextField(
                controller: _bloodGroup,
                hintText: 'E.g., A+, B-, O+',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 15),

              const Text('Preferred Language'),
              CustomTextField(
                controller: _language,
                hintText: 'Enter your preferred language',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),

              // Contact Information Section
              const Text(
                'Contact Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const Divider(),
              const SizedBox(height: 10),

              const Text('Phone Number'),
              CustomTextField(
                controller: _phone,
                hintText: 'Enter your phone number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),

              const Text('Emergency Contact'),
              CustomTextField(
                controller: _emergencyContact,
                hintText: 'Name and phone number',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 15),

              const Text('Mailing Address'),
              CustomTextField(
                controller: _mailingAddress,
                hintText: 'Enter your complete address',
                keyboardType: TextInputType.streetAddress,
                //maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Educational Background Section
              const Text(
                'Educational Background',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const Divider(),
              const SizedBox(height: 10),

              const Text('High School'),
              CustomTextField(
                controller: _highSchool,
                hintText: 'Enter your high school name',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 15),

              const Text('College'),
              CustomTextField(
                controller: _college,
                hintText: 'Enter your college name',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 15),

              const Text('Undergraduate Institution'),
              CustomTextField(
                controller: _undergradInstitution,
                hintText: 'Enter your undergraduate institution',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 30),

              // Submit Button
              CustomButton(text: 'Submit', onPressed: () {}),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
