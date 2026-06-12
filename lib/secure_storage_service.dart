import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  // Campos sensibles definidos
  static const String keyApiToken = 'api_token';
  static const String keyMasterKey = 'master_key';
  static const String keyUserPin = 'user_pin';
  static const String keySessionData = 'session_data';

  /// Inicializa los campos SOLO si no existen ya (para no sobrescribir tras borrado)
  static Future<void> initializeDefaultData() async {
    final existing = await _storage.readAll();
    if (existing.isEmpty) {
      await _storage.write(key: keyApiToken, value: 'sk_live_51MzX9KEn2X...');
      await _storage.write(key: keyMasterKey, value: 'AES-256-GCM-7890-XYZ');
      await _storage.write(key: keyUserPin, value: '8842');
      await _storage.write(
          key: keySessionData,
          value: '{"id": "user_001", "role": "admin"}');
      debugPrint('[SecureStorage] Datos sensibles inicializados.');
    } else {
      debugPrint('[SecureStorage] Datos ya existentes, no se reinicializan.');
    }
  }

  /// Elimina todo el contenido del almacenamiento seguro
  static Future<void> wipeAllData() async {
    await _storage.deleteAll();
    debugPrint(
        '[SecureStorage] ¡ALERTA! Todos los datos sensibles han sido eliminados remotamente.');
  }

  /// Lee todos los datos
  static Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }
}