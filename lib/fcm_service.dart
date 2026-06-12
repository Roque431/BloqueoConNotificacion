import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'secure_storage_service.dart';
import 'firebase_options.dart';

// Callback global que la HomeScreen puede registrar para recibir el evento de wipe
typedef WipeCallback = void Function();
WipeCallback? onWipeReceived;

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

      // Obtener el token del dispositivo
      String? token = await _messaging.getToken();
      debugPrint('[FCM] Token del dispositivo: $token');

      // Manejar mensajes en primer plano
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Manejar tap en notificación cuando la app está en background (no cerrada)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleForegroundMessage);
    }

    // Registrar handler de segundo plano/cerrado (debe ser top-level)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('[FCM] Mensaje recibido en primer plano: ${message.data}');

    final action = message.data['action'];

    if (action == 'wipe_data') {
      debugPrint('[FCM] Acción wipe_data detectada. Borrando datos...');
      await SecureStorageService.wipeAllData();
      // Notificar a la UI para que se refresque
      onWipeReceived?.call();
    }
  }
}

// Handler top-level OBLIGATORIO para mensajes en segundo plano / app cerrada
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // En background hay que reinicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('[FCM-BG] Mensaje en segundo plano: ${message.data}');

  if (message.data['action'] == 'wipe_data') {
    await SecureStorageService.wipeAllData();
    debugPrint('[FCM-BG] Datos borrados en segundo plano.');
  }
}