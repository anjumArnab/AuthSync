// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../views/create_acc_page.dart';
import '../views/signIn_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool _isGetStartedPressed = false;
  bool _isSignInPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo Circle with A
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF7B68EE),
                      Color(0xFF6A5ACD),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7B68EE).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // App Title
              const Text(
                'Auth Sync',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Secure Authentication Made Simple',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF718096),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // Get Started Button
              GestureDetector(
                onTapDown: (_) => setState(() => _isGetStartedPressed = true),
                onTapUp: (_) => setState(() => _isGetStartedPressed = false),
                onTapCancel: () => setState(() => _isGetStartedPressed = false),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateAccountPage(),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: _isGetStartedPressed
                          ? [
                              const Color(0xFF6A5ACD),
                              const Color(0xFF5B4BC4),
                            ]
                          : [
                              const Color(0xFF7B68EE),
                              const Color(0xFF6A5ACD),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7B68EE).withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sign In Text
              const Text(
                'Already have an account?',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF718096),
                ),
              ),

              const SizedBox(height: 8),

              // Sign In Link
              GestureDetector(
                onTapDown: (_) => setState(() => _isSignInPressed = true),
                onTapUp: (_) => setState(() => _isSignInPressed = false),
                onTapCancel: () => setState(() => _isSignInPressed = false),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SignInPage(),
                    ),
                  );
                },
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _isSignInPressed
                        ? const Color(0xFF5B4BC4)
                        : const Color(0xFF7B68EE),
                  ),
                  child: const Text('Sign In'),
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
