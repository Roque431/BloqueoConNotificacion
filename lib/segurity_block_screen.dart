import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SecurityBlockScreen extends StatelessWidget {
  final String reason;

  const SecurityBlockScreen({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050D1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.gpp_bad_rounded,
                size: 100,
                color: Color(0xFFFF4C6A),
              ),
              const SizedBox(height: 30),
              const Text(
                'Acceso Denegado',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1F35),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFFF4C6A).withOpacity(0.3)),
                ),
                child: Text(
                  reason,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFE8F4FF),
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Por razones de seguridad, esta aplicación no puede ejecutarse en dispositivos con configuraciones que comprometan la integridad de los datos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6B8CAE), fontSize: 14),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => SystemNavigator.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4C6A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Cerrar Aplicación',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
