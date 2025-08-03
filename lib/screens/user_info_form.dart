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

  // Step controller
  int _currentStep = 0;
  final PageController _pageController = PageController();

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

  // Validation methods for each step
  bool _validatePersonalInfo() {
    if (_fullname.text.isEmpty ||
        _dob.text.isEmpty ||
        _selectedGender == null ||
        _selectedBloodGroup == null ||
        _selectedLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please fill in all required personal information fields')),
      );
      return false;
    }
    return true;
  }

  bool _validateContactInfo() {
    if (_phone.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in the phone number')),
      );
      return false;
    }
    return true;
  }

  // Navigate to next step
  void _nextStep() {
    if (_currentStep == 0 && !_validatePersonalInfo()) {
      return;
    }
    if (_currentStep == 1 && !_validateContactInfo()) {
      return;
    }

    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Navigate to previous step
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveUserData() async {
    // Final validation
    if (!_validatePersonalInfo() || !_validateContactInfo()) {
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
    _pageController.dispose();
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

  // Step indicator widget
  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 3; i++)
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= _currentStep ? Colors.blue : Colors.grey[300],
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color:
                          i <= _currentStep ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (i < 2)
                Container(
                  width: 40,
                  height: 2,
                  color: i < _currentStep ? Colors.blue : Colors.grey[300],
                ),
            ],
          ),
      ],
    );
  }

  // Personal Information Step
  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Please provide your personal details',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const Divider(),
        const SizedBox(height: 20),

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
        const SizedBox(height: 30),

        CustomButton(
          text: 'Next: Contact Information',
          onPressed: _nextStep,
        ),
      ],
    );
  }

  // Contact Information Step
  Widget _buildContactInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Please provide your contact details',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const Divider(),
        const SizedBox(height: 20),
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
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomButton(
                text: 'Previous',
                onPressed: _previousStep,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomButton(
                text: 'Next: Education',
                onPressed: _nextStep,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Educational Information Step
  Widget _buildEducationalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Educational Background',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Please provide your educational background',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const Divider(),
        const SizedBox(height: 20),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomButton(
                text: 'Previous',
                onPressed: _previousStep,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomButton(
                text: _fullname.text.isEmpty ? 'Submit' : 'Update',
                onPressed: _saveUserData,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AuthSync'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Text(
              'Please enter your information',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Text('for ${_authService.currentUser!.email}'),
            const SizedBox(height: 20),

            // Step Indicator
            _buildStepIndicator(),
            const SizedBox(height: 30),

            // Form Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                children: [
                  SingleChildScrollView(child: _buildPersonalInfoStep()),
                  SingleChildScrollView(child: _buildContactInfoStep()),
                  SingleChildScrollView(child: _buildEducationalInfoStep()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
