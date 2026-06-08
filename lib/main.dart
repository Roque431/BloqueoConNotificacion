import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'inactivity_detector.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SecureAppWrapper());
}

class SecureAppWrapper extends StatelessWidget {
  const SecureAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final navigatorKey = GlobalKey<NavigatorState>();

    return InactivityDetector(
      timeout: const Duration(seconds: 30), // 30 segundos para pruebas, ajustar según necesidad
      onTimeout: () {
        debugPrint('[Inactivity] Tiempo de inactividad alcanzado. Bloqueando...');
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
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}