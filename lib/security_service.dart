import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SecurityService {
  static const _channel = MethodChannel('com.roque.bloquepantalla/security');

  /// Devuelve true si USB Debugging está activo EN MODO RELEASE.
  /// En debug siempre retorna false (para no bloquearte al desarrollar).
  static Future<bool> isUsbDebuggingEnabled() async {
    // En modo desarrollo nunca bloqueamos
    if (kDebugMode) return false;

    try {
      final bool result =
          await _channel.invokeMethod('isUsbDebuggingEnabled');
      return result;
    } on PlatformException catch (e) {
      debugPrint('[SecurityService] Error al verificar ADB: ${e.message}');
      return false; // ante error, no bloquear (fail open — ajustar según política)
    }
  }
}