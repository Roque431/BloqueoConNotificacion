import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'secure_storage_service.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Solicitar permisos (especialmente para iOS)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('[FCM] Permiso concedido.');
      
      // Obtener el token del dispositivo (útil para enviar notificaciones específicas)
      String? token = await _messaging.getToken();
      debugPrint('[FCM] Token del dispositivo: $token');

      // Manejar mensajes en primer plano
      FirebaseMessaging.onMessage.listen(_handleMessage);

      // Manejar mensajes en segundo plano/cerrado
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }
  }

  static void _handleMessage(RemoteMessage message) {
    debugPrint('[FCM] Mensaje recibido: ${message.data}');
    
    // Verificar si la notificación contiene la acción de borrado
    if (message.data['action'] == 'wipe_data') {
      SecureStorageService.wipeAllData();
    }
  }
}

// Función global obligatoria para segundo plano
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM-BG] Mensaje en segundo plano: ${message.data}');
  if (message.data['action'] == 'wipe_data') {
    await SecureStorageService.wipeAllData();
  }
}
