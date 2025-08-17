// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'signin_page.dart';
import '../widgets/custom_button.dart';
import '../widgets/account_card.dart';
import '../services/auth_service.dart';
import '../services/account_storage_service.dart';
import '../services/multi_account_manager.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final AuthService _authService = AuthService();
  int _selectedAccountIndex = -1;
  List<StoredAccount> _accounts = [];
  bool _isLoading = true;
  bool _isSwitching = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get all stored accounts
      final accounts = await _authService.getAllStoredAccounts();
      final activeAccount = await _authService.getActiveStoredAccount();

      // Filter out any null accounts and ensure list is valid
      final validAccounts =
          accounts.where((account) => account != null).toList();

      // Use mounted check before setState to prevent calling setState on disposed widget
      if (!mounted) return;

      setState(() {
        _accounts = validAccounts;
        _isLoading = false;

        // Set selected index to active account
        if (activeAccount != null && validAccounts.isNotEmpty) {
          _selectedAccountIndex = validAccounts.indexWhere(
            (account) => account.uid == activeAccount.uid,
          );
          // Only set to 0 if accounts list is not empty and no active account found
          if (_selectedAccountIndex == -1) {
            _selectedAccountIndex = 0;
          }
        } else {
          // If no active account or accounts list is empty
          _selectedAccountIndex = validAccounts.isNotEmpty ? 0 : -1;
        }
      });

      print(
          'DEBUG: Loaded ${validAccounts.length} accounts, selected index: $_selectedAccountIndex');
    } catch (e) {
      print('DEBUG: Error loading accounts: $e');

      if (!mounted) return;

      setState(() {
        _accounts = []; // Ensure accounts list is empty on error
        _isLoading = false;
        _selectedAccountIndex = -1;
      });
      _showErrorSnackBar('Failed to load accounts: ${e.toString()}');
    }
  }

  void _selectAccount(int index) {
    if (index >= 0 && index < _accounts.length) {
      setState(() {
        _selectedAccountIndex = index;
      });
    }
  }

  Future<void> _navigateToSignIn() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SignInPage(),
      ),
    );

    // If a new account was added, reload the accounts list
    if (result == true) {
      await _loadAccounts();
    }
  }

  Future<void> _switchAccount() async {
    // Add safety checks
    if (_accounts.isEmpty) {
      _showErrorSnackBar('No accounts available');
      return;
    }

    if (_selectedAccountIndex < 0 ||
        _selectedAccountIndex >= _accounts.length) {
      _showErrorSnackBar('Please select a valid account');
      return;
    }

    final selectedAccount = _accounts[_selectedAccountIndex];

    // Check if it's already the current user
    if (_authService.currentUser?.uid == selectedAccount.uid) {
      _showSuccessSnackBar('You are already signed in to this account');
      return;
    }

    setState(() {
      _isSwitching = true;
    });

    try {
      // Switch to the selected account directly without confirmation dialog
      final switchResponse = await _authService.switchToAccountWithFallback(
        selectedAccount.uid,
      );

      if (!mounted) return;

      setState(() {
        _isSwitching = false;
      });

      if (switchResponse.result == AccountSwitchResult.success) {
        _showSuccessSnackBar('Switched to ${selectedAccount.label}');
        // Reload accounts to update active status
        await _loadAccounts();
        // Go back to previous screen
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        _handleSwitchError(switchResponse);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSwitching = false;
      });
      _showErrorSnackBar('Failed to switch account: ${e.toString()}');
    }
  }

  void _handleSwitchError(AccountSwitchResponse response) {
    String message = response.message ?? 'Unknown error occurred';

    switch (response.result) {
      case AccountSwitchResult.tokenExpired:
      case AccountSwitchResult.tokenInvalid:
        message =
            'Account credentials have expired. The account has been removed. Please add it again.';
        // Reload accounts to reflect the removal
        _loadAccounts();
        break;
      case AccountSwitchResult.networkError:
        message =
            'Network error. Please check your internet connection and try again.';
        break;
      case AccountSwitchResult.userNotFound:
        message = 'Account not found. It may have been deleted.';
        _loadAccounts();
        break;
      default:
        break;
    }

    _showErrorSnackBar(message);
  }

  Future<void> _removeAccount(StoredAccount account) async {
    final confirmed = await _showRemoveConfirmationDialog(account);
    if (!confirmed) return;

    try {
      await _authService.removeStoredAccount(account.uid);
      _showSuccessSnackBar('Account removed successfully');
      await _loadAccounts();
    } catch (e) {
      _showErrorSnackBar('Failed to remove account: ${e.toString()}');
    }
  }

  Future<bool> _showRemoveConfirmationDialog(StoredAccount account) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Remove Account'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Remove ${account.label} from saved accounts?'),
                  const SizedBox(height: 8),
                  Text(
                    account.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This will not delete the account, only remove it from this device.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Remove'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        'DEBUG: Building UI - accounts: ${_accounts.length}, selected: $_selectedAccountIndex, loading: $_isLoading');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Accounts',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _isLoading ? null : _loadAccounts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6B73FF),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Account List
                  Expanded(
                    child: _accounts.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            itemCount: _accounts.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              print(
                                  'DEBUG: Building account card for index $index of ${_accounts.length}');

                              // Safety check to prevent RangeError
                              if (index < 0 || index >= _accounts.length) {
                                print(
                                    'DEBUG: Index out of range - returning empty widget');
                                return const SizedBox.shrink();
                              }

                              // Additional null safety check
                              final account = _accounts[index];
                              if (account == null) {
                                print(
                                    'DEBUG: Account at index $index is null - returning empty widget');
                                return const SizedBox.shrink();
                              }

                              // Use the new AccountCard widget
                              return AccountCard(
                                account: account,
                                index: index,
                                isSelected: index == _selectedAccountIndex,
                                authService: _authService,
                                onTap: () => _selectAccount(index),
                                onRemove: () => _removeAccount(account),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 16),

                  // Add Another Account Button
                  GestureDetector(
                    onTap: _navigateToSignIn,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          style: BorderStyle.solid,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add Another Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Switch Account Button
                  CustomButton(
                    label: _isSwitching ? 'Switching...' : 'Switch Account',
                    onPressed: _accounts.isEmpty ||
                            _isSwitching ||
                            _selectedAccountIndex < 0
                        ? null
                        : () {
                            print(
                                'DEBUG: Switch button pressed - accounts: ${_accounts.length}, selected: $_selectedAccountIndex');
                            _switchAccount();
                          },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No saved accounts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add an account to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
