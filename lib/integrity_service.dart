
import 'package:flutter/foundation.dart';
import 'package:safe_device/safe_device.dart';
import 'package:geolocator/geolocator.dart';

class IntegrityService {
  /// Verifica root/jailbreak y emulador. Se llama en main() antes de runApp().
  static Future<String?> checkDeviceIntegrity() async {
    try {
      bool isEmulator = await SafeDevice.isRealDevice == false;
      if (isEmulator && !kDebugMode) {
        return "No se permite el uso de emuladores por razones de seguridad.";
      }

      bool isJailBroken = await SafeDevice.isJailBroken;
      if (isJailBroken) {
        return "Dispositivo no íntegro detectado (Root/Jailbreak).";
      }

      return null;
    } catch (e) {
      debugPrint('Error en verificación de integridad: $e');
      return null;
    }
  }

  /// Verifica si la ubicación reportada es simulada (Fake GPS).
  /// Debe llamarse desde un contexto con UI lista (p.ej. initState de LoginScreen).
  /// Retorna true si se detecta mock location.
  static Future<bool> checkMockLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return false;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.low),
      );
      return position.isMocked;
    } catch (e) {
      debugPrint('Error verificando mock location: $e');
      return false;
    }
  }
}
