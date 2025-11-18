import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/snack_bar_helper.dart';
import '../widgets/gradient_button.dart';
import '../widgets/auth_field.dart';
import '../services/auth_service.dart';

class PhoneVerificationPage extends StatefulWidget {
  const PhoneVerificationPage({
    super.key,
  });

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedCountryCode = '+1';
  bool _isPhoneValid = false;
  bool _isSendingCode = false;
  String? _verificationId;

  final List<Map<String, String>> _countryCodes = [
    {'code': '+1', 'country': 'US', 'name': 'United States'},
    {'code': '+44', 'country': 'GB', 'name': 'United Kingdom'},
    {'code': '+33', 'country': 'FR', 'name': 'France'},
    {'code': '+49', 'country': 'DE', 'name': 'Germany'},
    {'code': '+81', 'country': 'JP', 'name': 'Japan'},
    {'code': '+86', 'country': 'CN', 'name': 'China'},
    {'code': '+91', 'country': 'IN', 'name': 'India'},
    {'code': '+61', 'country': 'AU', 'name': 'Australia'},
    {'code': '+55', 'country': 'BR', 'name': 'Brazil'},
    {'code': '+52', 'country': 'MX', 'name': 'Mexico'},
    {'code': '+88', 'country': 'BD', 'name': 'Bangladesh'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool _isValidPhoneNumber(String phone) {
    String digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length >= 11;
  }

  void _onPhoneChanged(String value) {
    setState(() {
      _isPhoneValid = value.isNotEmpty && _isValidPhoneNumber(value);
    });
  }

  String _getFullPhoneNumber() {
    String digitsOnly = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    return '$_selectedCountryCode$digitsOnly';
  }

  void _sendVerificationCode() async {
    if (!_isPhoneValid || _isSendingCode) return;

    setState(() {
      _isSendingCode = true;
    });

    String fullPhoneNumber = _getFullPhoneNumber();
    try {
      _authService.signInWithPhone(
          phoneNumber: fullPhoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) {},
          verificationFailed: (FirebaseAuthException e) {},
          codeSent: (String verificationId, int? resendToken) {
            _showCodeSentDialog();
            if (mounted) {
              setState(() {
                _isSendingCode = false;
                _verificationId = verificationId;
              });
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            if (mounted) {
              setState(() {
                _verificationId = verificationId;
              });
            }
          });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSendingCode = false;
        });
        SnackBarHelper.error(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Phone Sign In',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Phone Icon with Purple Background
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.smartphone,
                  color: Color(0xFF7B68EE),
                  size: 32,
                ),
              ),

              const SizedBox(height: 32),

              // Description Text
              const Text(
                'Enter your phone number to sign in with SMS verification',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Phone Number Input with Country Code
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Country Code Dropdown
                    GestureDetector(
                      onTap: _showCountryPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedCountryCode,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF9CA3AF),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Phone Number Input
                    Expanded(
                      child: AuthField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        hintText: 'Enter your phone number',
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(15),
                        ],
                        onChanged: _onPhoneChanged,
                        filled: false,
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Send Code Button
              GradientButton(
                label: _isSendingCode ? 'Sending Code...' : 'Send Code',
                onTap: (_isPhoneValid && !_isSendingCode)
                    ? _sendVerificationCode
                    : null,
                child: _isSendingCode
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : null,
              ),

              const SizedBox(height: 24),

              // SMS Agreement Text
              const Text(
                'By continuing, you agree to receive SMS messages from us',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Country',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _countryCodes.length,
                  itemBuilder: (context, index) {
                    final country = _countryCodes[index];
                    return ListTile(
                      leading: Container(
                        width: 32,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            country['country']!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        country['name']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Text(
                        country['code']!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCountryCode = country['code']!;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCodeSentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.sms,
                  color: Color(0xFF10B981),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Code Sent!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ve sent a verification code to\n${_getFullPhoneNumber()}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: 'Continue',
                onTap: () {
                  Navigator.of(context).pop();
                  if (_verificationId != null) {
                    Navigator.pushNamed(context, '/phone-verification-code',
                        arguments: {
                          'verificationId': _verificationId!,
                          'phoneNumber': _getFullPhoneNumber(),
                        });
                  } else {
                    SnackBarHelper.error(context,
                        'Verification ID not available. Please try again.');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

