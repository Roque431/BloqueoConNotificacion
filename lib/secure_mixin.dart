import 'package:flutter/material.dart';
import 'secure_screen_lock.dart';

mixin SecureScreenMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    activateSecureScreen();
  }

  @override
  void dispose() {
    deactivateSecureScreen();
    super.dispose();
  }
}