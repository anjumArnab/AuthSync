import 'package:app_links/app_links.dart';
import 'dart:async';

class AppLinkService {
  static AppLinkService? _instance;
  static AppLinkService get instance => _instance ??= AppLinkService._();
  AppLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  // Callback for when a reset password link is received
  void Function(String token)? onResetPasswordLink;

  // Initialize app link listening
  void initialize() {
    // Listen for incoming links
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleIncomingLink(uri);
      },
      onError: (err) {
        print('App link error: $err');
      },
    );
  }

  // Handle incoming app links
  void _handleIncomingLink(Uri uri) {
    print('Received app link: $uri');

    // Check if it's a password reset link
    if (uri.path == '/reset-password' ||
        uri.pathSegments.contains('reset-password')) {
      final token = uri.queryParameters['token'];
      if (token != null && onResetPasswordLink != null) {
        onResetPasswordLink!(token);
      }
    }
  }

  // Check for initial link when app starts
  Future<String?> getInitialResetToken() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        print('Initial app link: $uri');
        if (uri.path == '/reset-password' ||
            uri.pathSegments.contains('reset-password')) {
          return uri.queryParameters['token'];
        }
      }
    } catch (e) {
      print('Error getting initial link: $e');
    }
    return null;
  }

  // Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
  }
}
