import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_button.dart';

class PhoneVerificationCodePage extends StatefulWidget {
  const PhoneVerificationCodePage({super.key});

  @override
  State<PhoneVerificationCodePage> createState() =>
      _PhoneVerificationCodePageState();
}

class _PhoneVerificationCodePageState extends State<PhoneVerificationCodePage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  int _countdown = 47;
  late Timer _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    // Check if all fields are filled
    bool allFilled =
        _controllers.every((controller) => controller.text.isNotEmpty);
    if (allFilled) {
      // Auto verify when all fields are filled
      _verifyCode();
    }
  }

  void _verifyCode() {
    setState(() {
      _isVerifying = true;
    });

    String code = _controllers.map((controller) => controller.text).join();

    // Simulate verification process
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isVerifying = false;
      });

      // Handle verification result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification code: $code')),
      );
    });
  }

  void _resendCode() {
    setState(() {
      _countdown = 47;
    });
    _startCountdown();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code resent successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Title
            const Text(
              'Enter Code',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 40),

            // Phone icon in circle
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_android,
                size: 40,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 40),

            // Description text
            const Text(
              'We sent a 6-digit code to',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 8),

            // Phone number
            const Text(
              '+1 (555) 123-4567',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 40),

            // Code input fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45,
                  height: 55,
                  child: TextFormField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) => _onChanged(value, index),
                    onTap: () {
                      _controllers[index].selection =
                          TextSelection.fromPosition(
                        TextPosition(offset: _controllers[index].text.length),
                      );
                    },
                    onEditingComplete: () {
                      if (index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      }
                    },
                    onFieldSubmitted: (value) {
                      if (index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),

            const SizedBox(height: 40),

            // Verify button
            CustomButton(
              label: 'Verify Code',
              onPressed: _isVerifying ? null : _verifyCode,
            ),

            const SizedBox(height: 24),

            // Resend code text
            GestureDetector(
              onTap: _countdown == 0 ? _resendCode : null,
              child: Text(
                _countdown > 0
                    ? "Didn't receive code? Resend in 0:${_countdown.toString().padLeft(2, '0')}"
                    : "Didn't receive code? Resend",
                style: TextStyle(
                  fontSize: 14,
                  color: _countdown > 0 ? Colors.grey : Colors.blue,
                  fontWeight:
                      _countdown == 0 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
