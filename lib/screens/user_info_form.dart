import 'package:authsync/models/user.dart';
import 'package:authsync/screens/user_details.dart';
import 'package:authsync/services/authentication.dart';
import 'package:authsync/services/database.dart';
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

  final FirebaseAuthService _authService = FirebaseAuthService();
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService(uid: _authService.currentUser!.uid);
    _loadUserData();
  }

  void _navToUserDetailsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserDetailsPage(),
      ),
    );
  }

  Future<void> _loadUserData() async {
    try {
      UserModel? user = await _databaseService.getUserData();
      if (user != null) {
        setState(() {
          _fullname.text = user.fullName;
          _gender.text = user.gender;
          _dob.text = user.dateOfBirth;
          _bloodGroup.text = user.bloodGroup;
          _language.text = user.preferredLanguage;
          _phone.text = user.phoneNumber;
          _emergencyContact.text = user.emergencyContact;
          _mailingAddress.text = user.mailingAddress;
          _highSchool.text = user.highSchool;
          _college.text = user.college;
          _undergradInstitution.text = user.undergradInstitution;
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  Future<void> _saveUserData() async {
    try {
      UserModel user = UserModel(
        uid: _authService.currentUser!.uid,
        email: _authService.currentUser!.email!,
        fullName: _fullname.text,
        gender: _gender.text,
        dateOfBirth: _dob.text,
        bloodGroup: _bloodGroup.text,
        preferredLanguage: _language.text,
        phoneNumber: _phone.text,
        emergencyContact: _emergencyContact.text,
        mailingAddress: _mailingAddress.text,
        highSchool: _highSchool.text,
        college: _college.text,
        undergradInstitution: _undergradInstitution.text,
      );

      await _databaseService.saveUserData(user);
      _navToUserDetailsPage(context); // Go back to user details page
    } catch (e) {
      print("Error saving user data: $e");
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AuthSync'),
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
              CustomButton(text: 'Submit', onPressed: _saveUserData),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
