// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/snack_bar_helper.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _authService = AuthService();

  bool _isEmailVerified = false;
  bool _isInitialCheckLoading = true;
  bool _isResendAvailable = false;
  bool _isCheckingVerification = false;
  bool _isSendingEmail = false;
  int _resendCountdown = 60;
  Timer? _countdownTimer;
  Timer? _verificationCheckTimer;
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    currentUserEmail = _authService.getCurrentUserEmail();
    _performInitialVerificationCheck();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _verificationCheckTimer?.cancel();
    super.dispose();
  }

  void _performInitialVerificationCheck() async {
    try {
      bool isVerified = await _authService.isEmailVerified();
      if (mounted) {
        setState(() {
          _isEmailVerified = isVerified;
          _isInitialCheckLoading = false;
        });
        if (!isVerified) {
          _startCountdown();
          _startVerificationCheck();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isEmailVerified = false;
          _isInitialCheckLoading = false;
        });
        _startCountdown();
        _startVerificationCheck();
      }
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _isResendAvailable = false;
      _resendCountdown = 60;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0 && mounted) {
        setState(() => _resendCountdown--);
      } else if (mounted) {
        setState(() => _isResendAvailable = true);
        timer.cancel();
      }
    });
  }

  void _startVerificationCheck() {
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
          setState(() => _isEmailVerified = true);
        }
      } catch (e) {
        debugPrint('Error checking verification status: $e');
      }
    });
  }

  void _sendVerificationEmail() async {
    if (_isSendingEmail) return;
    setState(() => _isSendingEmail = true);

    try {
      await _authService.sendEmailVerification();
      if (mounted) {
        setState(() => _isSendingEmail = false);
        _startCountdown();
        SnackBarHelper.success(
            context, 'Verification email sent successfully!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSendingEmail = false);
        SnackBarHelper.error(context, e.toString());
      }
    }
  }

  void _checkVerificationManually() async {
    if (_isCheckingVerification) return;
    setState(() => _isCheckingVerification = true);

    try {
      bool isVerified = await _authService.isEmailVerified();
      if (mounted) {
        setState(() => _isCheckingVerification = false);
        if (isVerified) {
          setState(() => _isEmailVerified = true);
        } else {
          SnackBarHelper.warning(
              context, 'Email not verified yet. Please check your inbox.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingVerification = false);
        SnackBarHelper.error(
            context, 'Error checking verification: ${e.toString()}');
      }
    }
  }

  Widget _buildContent() {
    if (_isInitialCheckLoading) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF10B981)),
          SizedBox(height: 16),
          Text('Checking verification status...',
              style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      );
    }

    final isVerified = _isEmailVerified;
    final iconData =
        isVerified ? Icons.check_circle_outline : Icons.email_outlined;
    final iconColor = isVerified ? Colors.green : Colors.green;
    final title = isVerified ? 'Email Verified!' : 'Verify Your Email';
    final titleColor = isVerified ? Colors.green : Colors.black87;
    final description = isVerified
        ? 'Your email has been successfully verified. You can now access all features of your account.'
        : 'Please verify your email address to access all features of your account.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, size: 60, color: iconColor),
        ),
        const SizedBox(height: 32),
        Text(title,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: titleColor)),
        const SizedBox(height: 16),
        Text(description,
            textAlign: TextAlign.center,
            style:
                const TextStyle(color: Colors.grey, fontSize: 16, height: 1.4)),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isVerified
                ? Colors.green.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color:
                    isVerified ? Colors.green.shade200 : Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isVerified) ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  currentUserEmail ?? 'No email found',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isVerified ? Colors.green : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        if (isVerified)
          CustomButton(
              label: 'Continue',
              onPressed: () => Navigator.pop(context),
              backgroundColor: const Color(0xFF10B981))
        else ...[
          CustomButton(
            label: _isSendingEmail ? 'Sending...' : 'Send Verification Email',
            onPressed: _isResendAvailable && !_isSendingEmail
                ? _sendVerificationEmail
                : null,
            backgroundColor: const Color(0xFF6366F1),
            isEnabled: _isResendAvailable && !_isSendingEmail,
            isLoading: _isSendingEmail,
          ),
          const SizedBox(height: 16),
          CustomButton(
            label: _isCheckingVerification
                ? 'Checking...'
                : 'I\'ve Verified My Email',
            onPressed:
                _isCheckingVerification ? null : _checkVerificationManually,
            backgroundColor: const Color(0xFF10B981),
            isLoading: _isCheckingVerification,
          ),
          const SizedBox(height: 16),
          Text(
            _isResendAvailable
                ? 'Send verification email available'
                : 'Send verification email available in ${_resendCountdown}s',
            style: TextStyle(
              color:
                  _isResendAvailable ? Colors.green.shade600 : Colors.grey[600],
              fontSize: 14,
              fontWeight:
                  _isResendAvailable ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ],
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
        title: const Text(
          'Email Verification',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
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
                  48,
            ),
            child: IntrinsicHeight(child: _buildContent()),
          ),
        ),
      ),
    );
  }
}
