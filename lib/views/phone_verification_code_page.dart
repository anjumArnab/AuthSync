// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/snack_bar_helper.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';

class PhoneVerificationCodePage extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const PhoneVerificationCodePage({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<PhoneVerificationCodePage> createState() =>
      _PhoneVerificationCodePageState();
}

class _PhoneVerificationCodePageState extends State<PhoneVerificationCodePage> {
  final _authService = AuthService();

  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  int _countdown = 60;
  Timer? _timer;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _countdown = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0 && mounted) {
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
    _timer?.cancel();
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

  void _onKeyPressed(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_controllers[index].text.isEmpty && index > 0) {
          _focusNodes[index - 1].requestFocus();
          _controllers[index - 1].clear();
        }
      }
    }
  }

  void _verifyCode() async {
    if (_isVerifying) return;

    String code = _controllers.map((controller) => controller.text).join();

    if (code.length != 6) {
      SnackBarHelper.warning(context, 'Please enter the complete 6-digit code');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final credential = await _authService.signInWithPhoneCredential(
          verificationId: widget.verificationId, smsCode: code);

      if (credential != null && mounted) {
        setState(() {
          _isVerifying = false;
        });

        _showSuccessDialog('Phone Sign In Successful',
            'You have successfully signed in with your phone number.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });

        // Clear the input fields for retry
        _clearCodeFields();
        SnackBarHelper.error(context, _getErrorMessage(e.toString()));
      }
    }
  }

  void _resendCode() async {
    if (_isResending || _countdown > 0) return;

    setState(() {
      _isResending = true;
    });

    try {
      await _authService.signInWithPhone(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (credential) async {
          try {
            await _authService.signInWithPhoneCredential(
              verificationId: widget.verificationId,
              smsCode: '',
            );
          } catch (e) {
            if (mounted) {
              SnackBarHelper.error(context, e.toString());
            }
          }
        },
        verificationFailed: (e) {
          if (mounted) {
            setState(() {
              _isResending = false;
            });
            SnackBarHelper.error(context, e.message ?? 'Verification failed');
          }
        },
        codeSent: (verificationId, resendToken) {
          if (mounted) {
            setState(() {
              _isResending = false;
            });
            // Update verification ID for the new code

            Navigator.pushNamed(context, '/phone-verification-code',
                arguments: {
                  'verificationId': verificationId,
                  'phoneNumber': widget.phoneNumber,
                });
            SnackBarHelper.success(context, 'New verification code sent!');
          }
        },
        codeAutoRetrievalTimeout: (verificationId) {
          // Handle timeout if needed
        },
      );

      if (mounted) {
        _startCountdown();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
        SnackBarHelper.error(context, e.toString());
      }
    }
  }

  void _clearCodeFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous page
                // Optionally navigate to home/main page
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  String _getErrorMessage(String error) {
    if (error.contains('invalid-verification-code')) {
      return 'Invalid verification code. Please check and try again.';
    } else if (error.contains('session-expired')) {
      return 'Verification session expired. Please request a new code.';
    } else if (error.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }
    return 'Verification failed. Please try again.';
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
        title: const Text(
          'Phone Sign In',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
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
            Text(
              widget.phoneNumber,
              style: const TextStyle(
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
                  child: RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: (event) => _onKeyPressed(event, index),
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
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1,
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
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 40),

            // Verify button
            CustomButton(
              label: _isVerifying ? 'Verifying...' : 'Verify Code',
              onPressed: _isVerifying ? null : _verifyCode,
              isLoading: _isVerifying,
            ),

            const SizedBox(height: 24),

            // Resend code text
            GestureDetector(
              onTap: (_countdown == 0 && !_isResending) ? _resendCode : null,
              child: _isResending
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Sending new code...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      _countdown > 0
                          ? "Didn't receive code? Resend in 0:${_countdown.toString().padLeft(2, '0')}"
                          : "Didn't receive code? Resend",
                      style: TextStyle(
                        fontSize: 14,
                        color: _countdown > 0 ? Colors.grey : Colors.blue,
                        fontWeight: _countdown == 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
            ),

            const SizedBox(height: 32),

            // Help text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'The verification code will expire in 10 minutes. Make sure to enter it correctly.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
