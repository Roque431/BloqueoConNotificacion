
import 'package:flutter/foundation.dart';
import 'package:safe_device/safe_device.dart';
import 'package:trust_location/trust_location.dart';
import 'package:geolocator/geolocator.dart';

class IntegrityService {
  /// Verifica si el dispositivo es seguro para ejecutar la aplicación
  /// Retorna un mensaje de error si se detecta una amenaza, o null si es seguro.
  static Future<String?> checkDeviceIntegrity() async {
    try {
      // 1. Verificar si es un emulador
      bool isEmulator = await SafeDevice.isRealDevice == false;
      if (isEmulator && !kDebugMode) {
        return "No se permite el uso de emuladores por razones de seguridad.";
      }

      // 2. Verificar si el dispositivo tiene Root o Jailbreak
      bool isJailBroken = await SafeDevice.isJailBroken;
      if (isJailBroken) {
        return "Dispositivo no íntegro detectado (Root/Jailbreak).";
      }

      // 3. Verificar Fake GPS / Mock Location
      // Primero necesitamos permisos de ubicación para verificar esto
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        // trust_location verifica si la ubicación actual es simulada
        bool isMockLocation = await TrustLocation.isMockLocation;
        if (isMockLocation) {
          return "Se ha detectado el uso de una aplicación de Fake GPS. Por favor, desactívala para continuar.";
        }
      }

      // 4. Verificar si las opciones de desarrollador están activas (opcional, puede ser restrictivo)
      // bool isDevelopmentModeEnable = await SafeDevice.isDevelopmentModeEnable;
      // if (isDevelopmentModeEnable) {
      //   return "Por favor, desactiva las Opciones de Desarrollador.";
      // }

      return null; // Todo correcto
    } catch (e) {
      debugPrint('Error en verificación de integridad: $e');
      return null; // En caso de error, permitimos continuar para no bloquear usuarios legítimos por fallos técnicos
    }
  }
}
