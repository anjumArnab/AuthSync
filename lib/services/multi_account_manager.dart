import 'package:firebase_auth/firebase_auth.dart';
import 'account_storage_service.dart';
import 'custom_token_service.dart';
import '../models/account_switching_response.dart';
import '../models/stored_account.dart';

enum AccountSwitchResult {
  success,
  tokenExpired,
  tokenInvalid,
  networkError,
  userNotFound,
  unknownError,
}

class MultiAccountManager {
  final AccountStorageService _storageService = AccountStorageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add current account to storage
  Future<void> addCurrentAccountToStorage({
    String? label,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // Generate custom token for this user
      final tokenResponse =
          await CustomTokenService.generateCustomToken(user.uid);
      if (!tokenResponse.success || tokenResponse.customToken == null) {
        throw Exception(
            'Failed to generate custom token: ${tokenResponse.message}');
      }

      // Create StoredAccount object
      final account = StoredAccount(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoURL: user.photoURL,
        customToken: tokenResponse.customToken!,
        label: label ?? _generateDefaultLabel(user.email),
        createdAt: DateTime.now(),
        lastUsedAt: DateTime.now(),
      );

      // Store the account
      await _storageService.storeAccount(account);
      await _storageService.setActiveAccount(user.uid);
    } catch (e) {
      throw Exception('Failed to add account to storage: ${e.toString()}');
    }
  }

  // Switch to a different account
  Future<AccountSwitchResponse> switchToAccount(String uid) async {
    try {
      // Get stored account
      final account = await _storageService.getAccount(uid);
      if (account == null) {
        return AccountSwitchResponse(
          result: AccountSwitchResult.userNotFound,
          message: 'Account not found in storage',
        );
      }

      // Check if token is likely expired or invalid
      if (account.customToken.isEmpty ||
          CustomTokenService.isTokenLikelyExpired(account.customToken)) {
        // Try to refresh the token
        final refreshResult = await _refreshAccountToken(uid);
        if (refreshResult.result != AccountSwitchResult.success) {
          return refreshResult;
        }
      }

      // Get updated account with fresh token
      final updatedAccount = await _storageService.getAccount(uid);
      if (updatedAccount == null) {
        return AccountSwitchResponse(
          result: AccountSwitchResult.unknownError,
          message: 'Failed to retrieve updated account',
        );
      }

      // Sign in with custom token
      await _auth.signInWithCustomToken(updatedAccount.customToken);

      // Update active account and last used time
      await _storageService.setActiveAccount(uid);

      return AccountSwitchResponse(
        result: AccountSwitchResult.success,
        account: updatedAccount,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-custom-token' ||
          e.code == 'custom-token-mismatch') {
        return AccountSwitchResponse(
          result: AccountSwitchResult.tokenInvalid,
          message: 'Custom token is invalid: ${e.message}',
        );
      } else {
        return AccountSwitchResponse(
          result: AccountSwitchResult.unknownError,
          message: 'Firebase Auth error: ${e.message}',
        );
      }
    } catch (e) {
      return AccountSwitchResponse(
        result: AccountSwitchResult.unknownError,
        message: e.toString(),
      );
    }
  }

  // Refresh account token
  Future<AccountSwitchResponse> _refreshAccountToken(String uid) async {
    try {
      // First, we need to temporarily sign in to the account to get a fresh ID token
      // This is a limitation - needed to be authenticated as the user to generate their custom token

      final account = await _storageService.getAccount(uid);
      if (account == null) {
        return AccountSwitchResponse(
          result: AccountSwitchResult.userNotFound,
          message: 'Account not found',
        );
      }

      // Try to sign in with the existing token first
      try {
        await _auth.signInWithCustomToken(account.customToken);
      } catch (e) {
        // If that fails, we can't refresh the token automatically
        // The user would need to sign in manually again
        return AccountSwitchResponse(
          result: AccountSwitchResult.tokenExpired,
          message:
              'Token expired and cannot be refreshed automatically. Please sign in again.',
        );
      }

      // Generate new custom token
      final tokenResponse = await CustomTokenService.generateCustomToken(uid);
      if (!tokenResponse.success || tokenResponse.customToken == null) {
        return AccountSwitchResponse(
          result: AccountSwitchResult.networkError,
          message: 'Failed to refresh token: ${tokenResponse.message}',
        );
      }

      // Update stored account with new token
      await _storageService.updateAccountToken(uid, tokenResponse.customToken!);

      return AccountSwitchResponse(
        result: AccountSwitchResult.success,
        message: 'Token refreshed successfully',
      );
    } catch (e) {
      return AccountSwitchResponse(
        result: AccountSwitchResult.unknownError,
        message: 'Failed to refresh token: ${e.toString()}',
      );
    }
  }

  // Get all stored accounts
  Future<List<StoredAccount>> getAllAccounts() async {
    return await _storageService.getAccountsSortedByLastUsed();
  }

  // Get active account
  Future<StoredAccount?> getActiveAccount() async {
    return await _storageService.getActiveAccount();
  }

  // Remove account from storage
  Future<void> removeAccount(String uid) async {
    await _storageService.removeAccount(uid);
  }

  // Update account label
  Future<void> updateAccountLabel(String uid, String newLabel) async {
    await _storageService.updateAccountLabel(uid, newLabel);
  }

  // Check if current user is stored
  Future<bool> isCurrentUserStored() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    return await _storageService.accountExists(user.uid);
  }

  // Sync current user data with stored account
  Future<void> syncCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final account = await _storageService.getAccount(user.uid);
      if (account == null) return;

      // Update stored account with current user data
      final updatedAccount = account.copyWith(
        email: user.email ?? account.email,
        displayName: user.displayName ?? account.displayName,
        photoURL: user.photoURL ?? account.photoURL,
        lastUsedAt: DateTime.now(),
      );

      await _storageService.storeAccount(updatedAccount);
    } catch (e) {
      print('Error syncing user data: ${e.toString()}');
    }
  }

  // Clean up expired tokens for all accounts
  Future<void> cleanupExpiredTokens() async {
    await _storageService.cleanupExpiredTokens();
  }

  // Get account count
  Future<int> getAccountCount() async {
    return await _storageService.getAccountCount();
  }

  // Sign out and clear active account
  Future<void> signOutAndClearActive() async {
    await _auth.signOut();
    await _storageService.clearActiveAccount();
  }

  // Clear all accounts and sign out
  Future<void> clearAllAccountsAndSignOut() async {
    await _auth.signOut();
    await _storageService.clearAllAccounts();
  }

  // Switch to account with automatic fallback
  Future<AccountSwitchResponse> switchToAccountWithFallback(String uid) async {
    final result = await switchToAccount(uid);

    if (result.result == AccountSwitchResult.tokenExpired ||
        result.result == AccountSwitchResult.tokenInvalid) {
      // Token is expired/invalid, remove the account and ask user to re-add
      await removeAccount(uid);

      return AccountSwitchResponse(
        result: result.result,
        message:
            'Account removed due to expired credentials. Please add the account again.',
      );
    }

    return result;
  }

  // Generate default label for account
  String _generateDefaultLabel(String? email) {
    if (email == null || email.isEmpty) {
      return 'Account ${DateTime.now().millisecondsSinceEpoch}';
    }

    // Extract name from email
    final username = email.split('@')[0];
    return username.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ').trim();
  }

  // Get account by email
  Future<StoredAccount?> getAccountByEmail(String email) async {
    try {
      final accounts = await getAllAccounts();
      return accounts.firstWhere(
        (account) => account.email.toLowerCase() == email.toLowerCase(),
        orElse: () => throw StateError('Account not found'),
      );
    } catch (e) {
      return null;
    }
  }

  // Check if email is already stored
  Future<bool> isEmailAlreadyStored(String email) async {
    final account = await getAccountByEmail(email);
    return account != null;
  }

  // Refresh all account tokens (background task)
  Future<void> refreshAllAccountTokens() async {
    try {
      final accounts = await getAllAccounts();
      final currentUser = _auth.currentUser;

      for (final account in accounts) {
        // Skip current user as they are already authenticated
        if (currentUser?.uid == account.uid) continue;

        // Check if token needs refresh
        if (CustomTokenService.isTokenLikelyExpired(account.customToken)) {
          await _refreshAccountToken(account.uid);
        }
      }
    } catch (e) {
      print('Error refreshing account tokens: ${e.toString()}');
    }
  }

  // Clear active account
  Future<void> clearActiveAccount() async {
    await _storageService.clearActiveAccount();
  }

  // Set active account
  Future<void> setActiveAccount(String uid) async {
    await _storageService.setActiveAccount(uid);
  }

  // Get active account UID
  Future<String?> getActiveAccountUid() async {
    return await _storageService.getActiveAccountUid();
  }

  // Check if account exists
  Future<bool> accountExists(String uid) async {
    return await _storageService.accountExists(uid);
  }

  // Update last used time for account
  Future<void> updateLastUsed(String uid) async {
    await _storageService.updateLastUsed(uid);
  }

  // Get account by UID
  Future<StoredAccount?> getAccount(String uid) async {
    return await _storageService.getAccount(uid);
  }

  // Store account directly
  Future<void> storeAccount(StoredAccount account) async {
    await _storageService.storeAccount(account);
  }

  // Update account token
  Future<void> updateAccountToken(String uid, String newToken) async {
    await _storageService.updateAccountToken(uid, newToken);
  }

  // Clear all accounts
  Future<void> clearAllAccounts() async {
    await _storageService.clearAllAccounts();
  }
}
