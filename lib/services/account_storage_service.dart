import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/stored_account.dart';

class AccountStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const String _accountsKey = 'stored_accounts';
  static const String _activeAccountKey = 'active_account_uid';

  // Store a new account
  Future<void> storeAccount(StoredAccount account) async {
    try {
      final accounts = await getAllAccounts();

      // Update existing account or add new one
      final existingIndex = accounts.indexWhere((a) => a.uid == account.uid);
      if (existingIndex != -1) {
        accounts[existingIndex] = account;
      } else {
        accounts.add(account);
      }

      await _saveAccounts(accounts);
    } catch (e) {
      throw Exception('Failed to store account: ${e.toString()}');
    }
  }

  // Get all stored accounts
  Future<List<StoredAccount>> getAllAccounts() async {
    try {
      final accountsJson = await _storage.read(key: _accountsKey);
      if (accountsJson == null || accountsJson.isEmpty) {
        return [];
      }

      final List<dynamic> accountsList = json.decode(accountsJson);
      return accountsList.map((json) => StoredAccount.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to retrieve accounts: ${e.toString()}');
    }
  }

  // Get account by UID
  Future<StoredAccount?> getAccount(String uid) async {
    try {
      final accounts = await getAllAccounts();
      return accounts.firstWhere(
        (account) => account.uid == uid,
        orElse: () => throw StateError('Account not found'),
      );
    } catch (e) {
      return null;
    }
  }

  // Update account's last used time
  Future<void> updateLastUsed(String uid) async {
    try {
      final account = await getAccount(uid);
      if (account != null) {
        final updatedAccount = account.copyWith(lastUsedAt: DateTime.now());
        await storeAccount(updatedAccount);
      }
    } catch (e) {
      throw Exception('Failed to update last used time: ${e.toString()}');
    }
  }

  // Update account token
  Future<void> updateAccountToken(String uid, String newToken) async {
    try {
      final account = await getAccount(uid);
      if (account != null) {
        final updatedAccount = account.copyWith(
          customToken: newToken,
          lastUsedAt: DateTime.now(),
        );
        await storeAccount(updatedAccount);
      }
    } catch (e) {
      throw Exception('Failed to update account token: ${e.toString()}');
    }
  }

  // Remove account
  Future<void> removeAccount(String uid) async {
    try {
      final accounts = await getAllAccounts();
      accounts.removeWhere((account) => account.uid == uid);
      await _saveAccounts(accounts);

      // Clear active account if it was the removed one
      final activeUid = await getActiveAccountUid();
      if (activeUid == uid) {
        await clearActiveAccount();
      }
    } catch (e) {
      throw Exception('Failed to remove account: ${e.toString()}');
    }
  }

  // Clear all accounts
  Future<void> clearAllAccounts() async {
    try {
      await _storage.delete(key: _accountsKey);
      await clearActiveAccount();
    } catch (e) {
      throw Exception('Failed to clear all accounts: ${e.toString()}');
    }
  }

  // Set active account
  Future<void> setActiveAccount(String uid) async {
    try {
      await _storage.write(key: _activeAccountKey, value: uid);
      await updateLastUsed(uid);
    } catch (e) {
      throw Exception('Failed to set active account: ${e.toString()}');
    }
  }

  // Get active account UID
  Future<String?> getActiveAccountUid() async {
    try {
      return await _storage.read(key: _activeAccountKey);
    } catch (e) {
      return null;
    }
  }

  // Get active account
  Future<StoredAccount?> getActiveAccount() async {
    try {
      final activeUid = await getActiveAccountUid();
      if (activeUid != null) {
        return await getAccount(activeUid);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Clear active account
  Future<void> clearActiveAccount() async {
    try {
      await _storage.delete(key: _activeAccountKey);
    } catch (e) {
      throw Exception('Failed to clear active account: ${e.toString()}');
    }
  }

  // Get accounts sorted by last used (most recent first)
  Future<List<StoredAccount>> getAccountsSortedByLastUsed() async {
    try {
      final accounts = await getAllAccounts();
      accounts.sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
      return accounts;
    } catch (e) {
      throw Exception('Failed to get sorted accounts: ${e.toString()}');
    }
  }

  // Check if account exists
  Future<bool> accountExists(String uid) async {
    try {
      final account = await getAccount(uid);
      return account != null;
    } catch (e) {
      return false;
    }
  }

  // Get account count
  Future<int> getAccountCount() async {
    try {
      final accounts = await getAllAccounts();
      return accounts.length;
    } catch (e) {
      return 0;
    }
  }

  // Update account label
  Future<void> updateAccountLabel(String uid, String newLabel) async {
    try {
      final account = await getAccount(uid);
      if (account != null) {
        final updatedAccount = account.copyWith(label: newLabel);
        await storeAccount(updatedAccount);
      }
    } catch (e) {
      throw Exception('Failed to update account label: ${e.toString()}');
    }
  }

  // Private helper method to save accounts list
  Future<void> _saveAccounts(List<StoredAccount> accounts) async {
    try {
      final accountsJson = json.encode(
        accounts.map((account) => account.toJson()).toList(),
      );
      await _storage.write(key: _accountsKey, value: accountsJson);
    } catch (e) {
      throw Exception('Failed to save accounts: ${e.toString()}');
    }
  }

  // Clean up expired tokens (tokens older than 50 minutes)
  Future<void> cleanupExpiredTokens() async {
    try {
      final accounts = await getAllAccounts();
      final now = DateTime.now();
      bool hasExpiredTokens = false;

      for (var account in accounts) {
        // Check if token is older than 50 minutes (tokens expire in 1 hour)
        final tokenAge = now.difference(account.lastUsedAt);
        if (tokenAge.inMinutes > 50) {
          // Mark for token refresh by clearing the custom token
          final updatedAccount = account.copyWith(customToken: '');
          await storeAccount(updatedAccount);
          hasExpiredTokens = true;
        }
      }

      if (hasExpiredTokens) {
        print('Cleaned up expired tokens');
      }
    } catch (e) {
      print('Error cleaning up expired tokens: ${e.toString()}');
    }
  }
}
