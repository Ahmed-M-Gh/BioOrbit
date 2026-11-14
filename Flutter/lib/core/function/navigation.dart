import 'package:flutter/material.dart';

class AppNavigator {
  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.of(
      context,
    ).push<T>(MaterialPageRoute(builder: (_) => page));
  }

  static Future<T?> pushReplacement<T, TO>(BuildContext context, Widget page) {
    return Navigator.of(
      context,
    ).pushReplacement<T, TO>(MaterialPageRoute(builder: (_) => page));
  }

  static Future<T?> pushAndRemoveUntil<T>(BuildContext context, Widget page) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }
}
