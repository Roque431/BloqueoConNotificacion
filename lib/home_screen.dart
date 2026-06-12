import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'secure_mixin.dart';
import 'secure_storage_service.dart';
import 'fcm_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SecureScreenMixin {
  Map<String, String> _sensitiveData = {};
  String? _fcmToken;
  bool _wiped = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _getFCMToken();

    // Registrar callback: cuando llegue wipe_data desde FCM, refrescar la pantalla
    onWipeReceived = () {
      debugPrint('[HomeScreen] Wipe recibido, refrescando UI...');
      if (mounted) {
        setState(() {
          _sensitiveData = {};
          _wiped = true;
        });
      }
    };
  }

  @override
  void dispose() {
    // Limpiar el callback al salir de la pantalla
    onWipeReceived = null;
    super.dispose();
  }

  Future<void> _loadData() async {
    await SecureStorageService.initializeDefaultData();
    final data = await SecureStorageService.readAll();
    if (mounted) {
      setState(() {
        _sensitiveData = data;
        _wiped = data.isEmpty;
      });
    }
  }

  Future<void> _getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (mounted) {
      setState(() {
        _fcmToken = token;
      });
    }
  }

  Future<void> _manualWipe() async {
    await SecureStorageService.wipeAllData();
    setState(() {
      _sensitiveData = {};
      _wiped = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Seguridad'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar datos',
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Borrar datos manualmente',
            onPressed: _manualWipe,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              _wiped ? Icons.no_encryption_rounded : Icons.shield_rounded,
              size: 80,
              color: _wiped ? Colors.red : Colors.cyan,
            ),
            const SizedBox(height: 10),
            Text(
              _wiped ? '⚠️ Datos Eliminados' : 'Datos Sensibles Almacenados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _wiped ? Colors.red : null,
              ),
            ),
            const Text(
              'Envía una notificación FCM con action=wipe_data para borrarlos',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_wiped)
              const Card(
                color: Colors.redAccent,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.white, size: 40),
                      SizedBox(height: 8),
                      Text(
                        '¡DATOS ELIMINADOS REMOTAMENTE!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Todos los datos sensibles han sido borrados.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._sensitiveData.entries.map((e) => Card(
                    child: ListTile(
                      title: Text(e.key,
                          style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(e.value),
                      leading: const Icon(Icons.vpn_key, color: Colors.cyan),
                    ),
                  )),
            const SizedBox(height: 30),
            const Divider(),
            const Text(
              'Tu FCM Token (cópialo para enviar notificaciones desde Firebase Console):',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.cyan.withOpacity(0.3)),
              ),
              child: SelectableText(
                _fcmToken ?? 'Obteniendo token...',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 10, color: Colors.cyan),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}