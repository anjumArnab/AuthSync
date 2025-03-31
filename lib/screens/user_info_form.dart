import 'package:authsync/models/user.dart';
import 'package:authsync/screens/user_details.dart';
import 'package:authsync/services/authentication.dart';
import 'package:authsync/services/database.dart';
import 'package:authsync/widgets/custom_button.dart';
import 'package:authsync/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class UserInfoForm extends StatefulWidget {
  final UserModel userData; // Accept user data from UserDetailsPage
  const UserInfoForm({super.key, required this.userData});

  @override
  State<UserInfoForm> createState() => _UserInfoFormState();
}

class _UserInfoFormState extends State<UserInfoForm> {
  final TextEditingController _fullname = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _emergencyContact = TextEditingController();
  final TextEditingController _mailingAddress = TextEditingController();
  final TextEditingController _highSchool = TextEditingController();
  final TextEditingController _college = TextEditingController();
  final TextEditingController _undergradInstitution = TextEditingController();

  // Define static lists for dropdown items
  static const List<String> genderOptions = ['Male', 'Female', 'Other'];
  static const List<String> bloodGroupOptions = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];
  static const List<String> languageOptions = [
    'Bengali',
    'English',
    'Japanese'
  ];

  String? _selectedGender;
  String? _selectedBloodGroup;
  String? _selectedLanguage;

  final FirebaseAuthService _authService = FirebaseAuthService();
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService(uid: _authService.currentUser!.uid);
    _loadUserData();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _dob.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
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
          // Ensure the loaded values are in the predefined lists
          _selectedGender =
              genderOptions.contains(user.gender) ? user.gender : null;
          _dob.text = user.dateOfBirth;
          _selectedBloodGroup = bloodGroupOptions.contains(user.bloodGroup)
              ? user.bloodGroup
              : null;
          _selectedLanguage = languageOptions.contains(user.preferredLanguage)
              ? user.preferredLanguage
              : null;
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
    // Add validation to ensure all required dropdowns are selected
    if (_selectedGender == null ||
        _selectedBloodGroup == null ||
        _selectedLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all dropdown values')),
      );
      return;
    }

    // Validate required text fields
    if (_fullname.text.isEmpty || _dob.text.isEmpty || _phone.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      UserModel user = UserModel(
        uid: _authService.currentUser!.uid,
        email: _authService.currentUser!.email!,
        fullName: _fullname.text,
        gender: _selectedGender!,
        dateOfBirth: _dob.text,
        bloodGroup: _selectedBloodGroup!,
        preferredLanguage: _selectedLanguage!,
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
    _dob.dispose();
    _phone.dispose();
    _emergencyContact.dispose();
    _mailingAddress.dispose();
    _highSchool.dispose();
    _college.dispose();
    _undergradInstitution.dispose();
    super.dispose();
  }

  // Helper method to create dropdown buttons with consistent styling
  Widget _buildDropdownButton<T>({
    required List<T> items,
    required T? value,
    required void Function(T?) onChanged,
    required String hint,
  }) {
    return DropdownButton<T>(
      value: value,
      hint: Text(hint),
      items: items.map((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
      onChanged: onChanged,
    );
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

              const Text('Full Name *'),
              CustomTextField(
                controller: _fullname,
                hintText: 'Enter your full name',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 15),

              const Text('Date of Birth *'),
              TextField(
                controller: _dob,
                readOnly: true,
                decoration: const InputDecoration(
                  hintText: 'DD/MM/YYYY',
                  border: OutlineInputBorder(),
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 15),

              // Dropdown Row
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  // Gender Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Gender *'),
                      _buildDropdownButton<String>(
                        items: genderOptions,
                        value: _selectedGender,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGender = newValue;
                          });
                        },
                        hint: 'Select Gender',
                      ),
                    ],
                  ),

                  // Blood Group Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Blood Group *'),
                      _buildDropdownButton<String>(
                        items: bloodGroupOptions,
                        value: _selectedBloodGroup,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedBloodGroup = newValue;
                          });
                        },
                        hint: 'Select Blood Group',
                      ),
                    ],
                  ),

                  // Language Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Language *'),
                      _buildDropdownButton<String>(
                        items: languageOptions,
                        value: _selectedLanguage,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedLanguage = newValue;
                          });
                        },
                        hint: 'Select Language',
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Contact Information Section
              const Text(
                'Contact Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const Divider(),
              const SizedBox(height: 10),

              const Text('Phone Number *'),
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
              CustomButton(
                  text: _fullname.text.isEmpty ? 'Submit' : 'Update',
                  onPressed: _saveUserData),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
