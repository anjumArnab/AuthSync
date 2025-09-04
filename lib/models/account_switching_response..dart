import 'package:authsync/models/stored_account.dart';
import 'package:authsync/services/multi_account_manager.dart';

class AccountSwitchResponse {
  final AccountSwitchResult result;
  final String? message;
  final StoredAccount? account;

  AccountSwitchResponse({
    required this.result,
    this.message,
    this.account,
  });
}
