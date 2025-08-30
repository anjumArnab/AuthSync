import 'package:flutter/material.dart';

class SnackBarHelper {
  static void show(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.black,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: action,
      ),
    );
  }

  // Success snackbar
  static void success(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Colors.green,
    );
  }

  // Error snackbar
  static void error(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: 'OK',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
  }

  // Warning snackbar
  static void warning(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Colors.orange,
    );
  }

  // Info snackbar
  static void info(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Colors.blue,
    );
  }
}
