import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'segurity_block_screen.dart';
import 'inactivity_detector.dart';
import 'fcm_service.dart';
import 'secure_storage_service.dart';
import 'integrity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Verificar integridad del dispositivo (Fake GPS, Root, etc.)
  String? securityThreat = await IntegrityService.checkDeviceIntegrity();

  // 2. Inicializar Firebase (requiere google-services.json en Android)
  try {
    await Firebase.initializeApp();
    await FCMService.initialize();
  } catch (e) {
    debugPrint('Firebase no inicializado: $e');
  }

  // 3. Inicializar datos sensibles de prueba
  try {
    await SecureStorageService.initializeDefaultData();
  } catch (e) {
    debugPrint('Error inicializando almacenamiento seguro: $e');
  }

  runApp(SecureAppWrapper(securityThreat: securityThreat));
}

class SecureAppWrapper extends StatelessWidget {
  final String? securityThreat;
  const SecureAppWrapper({super.key, this.securityThreat});

  @override
  Widget build(BuildContext context) {
    final navigatorKey = GlobalKey<NavigatorState>();

    return InactivityDetector(
      timeout: const Duration(seconds: 30),
      onTimeout: () {
        navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
      },
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Acceso Seguro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0A1628),
            brightness: Brightness.dark,
          ),
        ),
        // Si hay una amenaza de seguridad, mostramos la pantalla de bloqueo
        home: securityThreat != null 
            ? SecurityBlockScreen(reason: securityThreat!) 
            : const LoginScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

