import 'package:flutter/foundation.dart';
// import 'package:flutter_windowmanager/flutter_windowmanager.dart'; // Descomentar cuando se agregue la dependencia

Future<void> activateSecureScreen() async {
  debugPrint('[SecureScreen] Activando protección contra capturas de pantalla');
  // try {
  //   await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  // } catch (e) {
  //   debugPrint('Error activando FLAG_SECURE: $e');
  // }
}

Future<void> deactivateSecureScreen() async {
  debugPrint('[SecureScreen] Desactivando protección contra capturas de pantalla');
  // try {
  //   await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
  // } catch (e) {
  //   debugPrint('Error desactivando FLAG_SECURE: $e');
  // }
}