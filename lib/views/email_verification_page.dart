// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _authService = AuthService(); // Initialize AuthService

  bool _isResendAvailable = false;
  bool _isCheckingVerification = false;
  bool _isSendingEmail = false;
  int _resendCountdown = 60; // Standard 60 seconds countdown
  Timer? _countdownTimer;
  Timer? _verificationCheckTimer;
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    currentUserEmail = _authService.getCurrentUserEmail();
    _startCountdown();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _verificationCheckTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _isResendAvailable = false;
      _resendCountdown = 60;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0 && mounted) {
        setState(() {
          _resendCountdown--;
        });
      } else if (mounted) {
        setState(() {
          _isResendAvailable = true;
        });
        timer.cancel();
      }
    });
  }

  void _startVerificationCheck() {
    // Check verification status every 3 seconds
    _verificationCheckTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      try {
        bool isVerified = await _authService.isEmailVerified();
        if (isVerified && mounted) {
          timer.cancel();
          _showVerificationSuccessDialog();
        }
      } catch (e) {
        // Silently handle errors in background checking
        debugPrint('Error checking verification status: $e');
      }
    });
  }

  void _sendVerificationEmail() async {
    if (_isSendingEmail) return;

    setState(() {
      _isSendingEmail = true;
    });

    try {
      await _authService.sendEmailVerification();

      if (mounted) {
        setState(() {
          _isSendingEmail = false;
        });
        _startCountdown();
        _showSnackBar(
          'Verification email sent successfully!',
          Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSendingEmail = false;
        });
        _showSnackBar(
          e.toString(),
          Colors.red,
        );
      }
    }
  }

  void _checkVerificationManually() async {
    if (_isCheckingVerification) return;

    setState(() {
      _isCheckingVerification = true;
    });

    try {
      bool isVerified = await _authService.isEmailVerified();

      if (mounted) {
        setState(() {
          _isCheckingVerification = false;
        });

        if (isVerified) {
          _showVerificationSuccessDialog();
        } else {
          _showSnackBar(
            'Email not verified yet. Please check your inbox.',
            Colors.orange,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingVerification = false;
        });
        _showSnackBar(
          'Error checking verification: ${e.toString()}',
          Colors.red,
        );
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showVerificationSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('Email Verified!'),
            ],
          ),
          content: const Text(
            'Your email has been successfully verified. You can now access all features of your account.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous page
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  void _navigateBack() {
    Navigator.of(context).pop();
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
          onPressed: _navigateBack,
        ),
        title: const Text(
          'Email Verification',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight -
                  48, // Account for padding and app bar
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Email icon with green background
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.email_outlined,
                      size: 60,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  const Text(
                    'Verify Your Email',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description text
                  const Text(
                    'We\'ve sent a verification link to your email address. Click the link to verify your account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Email address
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      currentUserEmail ?? 'No email found',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Check Verification Button
                  CustomButton(
                    label: _isCheckingVerification
                        ? 'Checking...'
                        : 'I\'ve Verified My Email',
                    onPressed: _isCheckingVerification
                        ? null
                        : _checkVerificationManually,
                    backgroundColor: const Color(0xFF10B981),
                    isLoading: _isCheckingVerification,
                  ),

                  const SizedBox(height: 16),

                  // Send Verification Email button
                  CustomButton(
                    label: _isSendingEmail
                        ? 'Sending...'
                        : 'Resend Verification Email',
                    onPressed: _isResendAvailable && !_isSendingEmail
                        ? _sendVerificationEmail
                        : null,
                    backgroundColor: const Color(0xFF6366F1),
                    isEnabled: _isResendAvailable && !_isSendingEmail,
                    isLoading: _isSendingEmail,
                  ),

                  const SizedBox(height: 16),

                  // Resend availability text
                  Text(
                    _isResendAvailable
                        ? 'Resend available now'
                        : 'Resend available in ${_resendCountdown}s',
                    style: TextStyle(
                      color: _isResendAvailable
                          ? Colors.green.shade600
                          : Colors.grey[600],
                      fontSize: 14,
                      fontWeight: _isResendAvailable
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
