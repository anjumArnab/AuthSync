// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../services/account_storage_service.dart';
import '../services/auth_service.dart';

class AccountCard extends StatelessWidget {
  final StoredAccount account;
  final int index;
  final bool isSelected;
  final AuthService authService;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const AccountCard({
    super.key,
    required this.account,
    required this.index,
    required this.isSelected,
    required this.authService,
    required this.onTap,
    required this.onRemove,
  });

  String _getInitials(StoredAccount account) {
    try {
      if (account.displayName != null && account.displayName!.isNotEmpty) {
        final parts = account.displayName!.trim().split(' ');
        if (parts.length >= 2) {
          return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
        }
        return account.displayName![0].toUpperCase();
      }

      if (account.email.isNotEmpty) {
        return account.email[0].toUpperCase();
      }

      return 'U';
    } catch (e) {
      return 'U';
    }
  }

  Color _getAccountColor(int index) {
    final colors = [
      const Color(0xFF6B73FF),
      const Color(0xFFFF9500),
      const Color(0xFF9C27B0),
      const Color(0xFF4CAF50),
      const Color(0xFFF44336),
      const Color(0xFF2196F3),
      const Color(0xFFFF5722),
      const Color(0xFF607D8B),
    ];
    return colors[index % colors.length];
  }

  bool _isCurrentUser(StoredAccount account) {
    try {
      return authService.currentUser?.uid == account.uid;
    } catch (e) {
      return false;
    }
  }

  String _formatLastUsed(DateTime lastUsed) {
    try {
      final now = DateTime.now();
      final difference = now.difference(lastUsed);

      if (difference.inDays > 7) {
        return '${lastUsed.day}/${lastUsed.month}/${lastUsed.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      bool isCurrentlySignedIn = _isCurrentUser(account);

      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF6B73FF) : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getAccountColor(index),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getInitials(account),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Account Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            account.label,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentlySignedIn) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Active',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      account.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last used: ${_formatLastUsed(account.lastUsedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Remove button
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    onPressed: onRemove,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  // Selection Indicator / Arrow
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF6B73FF),
                      size: 24,
                    )
                  else
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                      size: 24,
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('DEBUG: Error building account card: $e');
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('Error loading account'),
      );
    }
  }
}
