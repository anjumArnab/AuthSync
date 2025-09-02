import 'package:firebase_auth/firebase_auth.dart';
import 'multi_account_manager.dart';
import 'account_storage_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MultiAccountManager _multiAccountManager = MultiAccountManager();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user stream for listening to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get multi-account manager instance
  MultiAccountManager get multiAccountManager => _multiAccountManager;

  // Sign In with Email and Password (Enhanced with multi-account support)
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
    bool addToStorage = true,
    String? accountLabel,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add to multi-account storage if requested
      if (addToStorage && result.user != null) {
        try {
          // Check if account is already stored
          final isAlreadyStored =
              await _multiAccountManager.isEmailAlreadyStored(email);

          if (!isAlreadyStored) {
            await _multiAccountManager.addCurrentAccountToStorage(
              label: accountLabel,
            );
          } else {
            // Sync existing account data
            await _multiAccountManager.syncCurrentUserData();
            // Set as active account
            await _multiAccountManager.setActiveAccount(result.user!.uid);
          }
        } catch (e) {
          // Don't fail the sign-in if storage fails
          print('Warning: Failed to add account to storage: ${e.toString()}');
        }
      }

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
    bool addToStorage = true,
    String? accountLabel,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          verificationCompleted(credential);

          // Add to storage after successful verification
          if (addToStorage && _auth.currentUser != null) {
            try {
              await _multiAccountManager.addCurrentAccountToStorage(
                label: accountLabel ?? phoneNumber,
              );
            } catch (e) {
              print(
                  'Warning: Failed to add phone account to storage: ${e.toString()}');
            }
          }
        },
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      throw Exception('Phone verification failed: ${e.toString()}');
    }
  }

  // Phone sign in with SMS code
  Future<UserCredential?> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
    bool addToStorage = true,
    String? accountLabel,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential result = await _auth.signInWithCredential(credential);

      // Add to storage if requested
      if (addToStorage && result.user != null) {
        try {
          await _multiAccountManager.addCurrentAccountToStorage(
            label: accountLabel ?? result.user!.phoneNumber,
          );
        } catch (e) {
          print(
              'Warning: Failed to add phone account to storage: ${e.toString()}');
        }
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw Exception('Phone sign in failed: ${e.toString()}');
    }
  }

  // Create Account (Sign Up)
  Future<UserCredential?> createAccount({
    required String email,
    required String password,
    String? displayName,
    bool addToStorage = true,
    String? accountLabel,
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

      // Add to multi-account storage if requested
      if (addToStorage && result.user != null) {
        try {
          await _multiAccountManager.addCurrentAccountToStorage(
            label: accountLabel,
          );
        } catch (e) {
          print(
              'Warning: Failed to add new account to storage: ${e.toString()}');
        }
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw Exception('Account creation failed: ${e.toString()}');
    }
  }

  // Change Password
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

      // Sync account data after password change
      await _multiAccountManager.syncCurrentUserData();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw Exception('Password change failed: ${e.toString()}');
    }
  }

  // Update Email
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
      await user.verifyBeforeUpdateEmail(newEmail);

      // Sync account data after email change
      await _multiAccountManager.syncCurrentUserData();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw Exception('Email update failed: ${e.toString()}');
    }
  }

  // Delete Account (Enhanced with storage cleanup)
  Future<void> deleteAccount({required String password}) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final uid = user.uid;

      // Re-authenticate user before deleting account
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Remove from storage first
      try {
        await _multiAccountManager.removeAccount(uid);
      } catch (e) {
        print(
            'Warning: Failed to remove account from storage: ${e.toString()}');
      }

      // Delete account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw Exception('Account deletion failed: ${e.toString()}');
    }
  }

  // Forgot Password
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset email failed: ${e.toString()}');
    }
  }

  // Phone Verification Code (Start verification process)
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

  // Email Verification
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

  // Sign Out (Enhanced with multi-account support)
  Future<void> signOut({bool clearActiveAccount = true}) async {
    try {
      await _auth.signOut();

      if (clearActiveAccount) {
        await _multiAccountManager
            .clearActiveAccount(); // FIXED: use public method
      }
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Switch to another account
  Future<AccountSwitchResponse> switchToAccount(String uid) async {
    return await _multiAccountManager.switchToAccount(uid);
  }

  // Switch to account with automatic fallback
  Future<AccountSwitchResponse> switchToAccountWithFallback(String uid) async {
    return await _multiAccountManager.switchToAccountWithFallback(uid);
  }

  // Add current account to storage manually
  Future<void> addCurrentAccountToStorage({String? label}) async {
    await _multiAccountManager.addCurrentAccountToStorage(label: label);
  }

  // Get all stored accounts
  Future<List<StoredAccount>> getAllStoredAccounts() async {
    return await _multiAccountManager.getAllAccounts();
  }

  // Get active stored account
  Future<StoredAccount?> getActiveStoredAccount() async {
    return await _multiAccountManager.getActiveAccount();
  }

  // Remove account from storage
  Future<void> removeStoredAccount(String uid) async {
    await _multiAccountManager.removeAccount(uid);
  }

  // Update account label
  Future<void> updateStoredAccountLabel(String uid, String newLabel) async {
    await _multiAccountManager.updateAccountLabel(uid, newLabel);
  }

  // Check if current user is stored
  Future<bool> isCurrentUserStored() async {
    return await _multiAccountManager.isCurrentUserStored();
  }

  // Get stored account count
  Future<int> getStoredAccountCount() async {
    return await _multiAccountManager.getAccountCount();
  }

  // Clear all stored accounts and sign out
  Future<void> clearAllAccountsAndSignOut() async {
    await _multiAccountManager.clearAllAccountsAndSignOut();
  }

  // Clean up expired tokens
  Future<void> cleanupExpiredTokens() async {
    await _multiAccountManager.cleanupExpiredTokens();
  }

  // Check if email is already stored
  Future<bool> isEmailAlreadyStored(String email) async {
    return await _multiAccountManager.isEmailAlreadyStored(email);
  }

  // Get account by email
  Future<StoredAccount?> getStoredAccountByEmail(String email) async {
    return await _multiAccountManager.getAccountByEmail(email);
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
      case 'invalid-custom-token':
        return 'The custom token is invalid.';
      case 'custom-token-mismatch':
        return 'The custom token corresponds to a different audience.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }

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

      // Sync account data after display name change
      await _multiAccountManager.syncCurrentUserData();
    } catch (e) {
      throw Exception('Display name update failed: ${e.toString()}');
    }
  }

  // Reload current user
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();

      // Sync account data after reload
      if (_auth.currentUser != null) {
        await _multiAccountManager.syncCurrentUserData();
      }
    } catch (e) {
      throw Exception('User reload failed: ${e.toString()}');
    }
  }

  // Initialize multi-account functionality (call this on app startup)
  Future<void> initializeMultiAccount() async {
    try {
      // Clean up any expired tokens
      await cleanupExpiredTokens();

      // If user is currently signed in, sync their data
      if (isUserSignedIn()) {
        await _multiAccountManager.syncCurrentUserData();
      }
    } catch (e) {
      print(
          'Warning: Failed to initialize multi-account functionality: ${e.toString()}');
    }
  }

  // Get account switch history (sorted by last used)
  Future<List<StoredAccount>> getAccountHistory() async {
    return await _multiAccountManager.getAllAccounts();
  }

  // Quick switch to most recently used account (excluding current)
  Future<AccountSwitchResponse?> switchToLastUsedAccount() async {
    try {
      final accounts = await getAccountHistory();
      final currentUid = currentUser?.uid;

      // Find the first account that's not the current user
      for (final account in accounts) {
        if (account.uid != currentUid) {
          return await switchToAccount(account.uid);
        }
      }

      return null; // No other accounts found
    } catch (e) {
      return AccountSwitchResponse(
        result: AccountSwitchResult.unknownError,
        message: 'Failed to switch to last used account: ${e.toString()}',
      );
    }
  }
}
