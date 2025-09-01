// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../widgets/gradient_button.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
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
              GradientButton(
                label: 'Get Started',
                onTap: () {
                  Navigator.pushNamed(context, '/create-account');
                },
              ),

              const SizedBox(height: 24),

              // Sign In Link
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/sign-in'),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Color(0xFF7B68EE),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
