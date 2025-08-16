import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user stream for listening to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 1. Sign In with Email and Password
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Sign In with Phone Number (requires verification)
  Future<void> signInWithPhone({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      throw Exception('Phone verification failed: ${e.toString()}');
    }
  }

  // Complete phone sign in with SMS code
  Future<UserCredential?> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential result = await _auth.signInWithCredential(credential);
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw Exception('Phone sign in failed: ${e.toString()}');
    }
  }

  // 2. Create Account (Sign Up)
  Future<UserCredential?> createAccount({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await result.user?.updateDisplayName(displayName);
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw Exception('Account creation failed: ${e.toString()}');
    }
  }

  // 3. Change Password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // Re-authenticate user before changing password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw Exception('Password change failed: ${e.toString()}');
    }
  }

  // 4. Update Email
  Future<void> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // Re-authenticate user before updating email
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Update email
      await user.updateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw Exception('Email update failed: ${e.toString()}');
    }
  }

  // 5. Delete Account
  Future<void> deleteAccount({required String password}) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // Re-authenticate user before deleting account
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Delete account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw Exception('Account deletion failed: ${e.toString()}');
    }
  }

  // 6. Forgot Password
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw Exception('Password reset email failed: ${e.toString()}');
    }
  }

  // 7. Phone Verification Code (Start verification process)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      throw Exception('Phone verification failed: ${e.toString()}');
    }
  }

  // Verify phone with SMS code
  Future<UserCredential?> verifyPhoneWithCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // If user is already signed in, link the phone number
      if (_auth.currentUser != null) {
        return await _auth.currentUser!.linkWithCredential(credential);
      } else {
        // Otherwise, sign in with phone credential
        return await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw Exception('Phone verification failed: ${e.toString()}');
    }
  }

  // 8. Email Verification
  Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification();
      } else {
        throw Exception('Email is already verified');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw Exception('Email verification failed: ${e.toString()}');
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    if (user == null) return false;

    // Reload user to get the latest verification status
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // 9. Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Helper method to handle Firebase Auth errors
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support.';
      case 'invalid-verification-code':
        return 'The verification code is invalid.';
      case 'invalid-verification-id':
        return 'The verification ID is invalid.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      case 'credential-already-in-use':
        return 'This credential is already associated with another user account.';
      case 'invalid-credential':
        return 'The credential is malformed or has expired.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }

  // Additional utility methods

  // Check if user is signed in
  bool isUserSignedIn() {
    return _auth.currentUser != null;
  }

  // Get current user email
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  // Get current user display name
  String? getCurrentUserDisplayName() {
    return _auth.currentUser?.displayName;
  }

  // Get current user phone number
  String? getCurrentUserPhoneNumber() {
    return _auth.currentUser?.phoneNumber;
  }

  // Update display name
  Future<void> updateDisplayName({required String displayName}) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      await user.updateDisplayName(displayName);
    } catch (e) {
      throw Exception('Display name update failed: ${e.toString()}');
    }
  }

  // Reload current user
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      throw Exception('User reload failed: ${e.toString()}');
    }
  }
}
