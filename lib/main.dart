import 'package:flutter/material.dart';
import '../firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../views/homepage.dart';
import '../views/profile_page.dart';
import '../views/accounts_page.dart';
import '../views/change_password_page.dart';
import '../views/create_acc_page.dart';
import '../views/delete_account_page.dart';
import '../views/email_verification_page.dart';
import '../views/forgot_password_page.dart';
import '../views/phone_verification_code_page.dart';
import '../views/phone_verification_page.dart';
import '../views/signin_page.dart';
import '../views/update_email_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const AuthSync());
}

class AuthSync extends StatelessWidget {
  const AuthSync({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AuthSync',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      routes: {
        '/home': (context) => const Homepage(),
        '/profile': (context) => const ProfilePage(),
        '/authcheck': (context) => const AuthCheck(),
        '/sign-in': (context) => const SignInPage(),
        '/account': (context) => const AccountsPage(),
        '/update-email': (context) => const UpdateEmailPage(),
        '/delete-account': (context) => const DeleteAccountPage(),
        '/create-account': (context) => const CreateAccountPage(),
        '/change-password': (context) => const ChangePasswordPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/verify-email': (context) => const EmailVerificationPage(),
        '/phone-verification': (context) => const PhoneVerificationPage(),
        '/phone-verification-code': (context) =>
            const PhoneVerificationCodePage(
              verificationId: '',
              phoneNumber: '',
            ),
      },
      initialRoute: '/authcheck',
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const ProfilePage(); // User is logged in
        } else {
          return const Homepage(); // User is not logged in
        }
      },
    );
  }
}
