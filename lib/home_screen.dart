import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'secure_mixin.dart';
import 'secure_storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SecureScreenMixin {
  Map<String, String> _sensitiveData = {};
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _loadData();
    _getFCMToken();
  }

  Future<void> _loadData() async {
    final data = await SecureStorageService.readAll();
    setState(() {
      _sensitiveData = data;
    });
  }

  Future<void> _getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    setState(() {
      _fcmToken = token;
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
            onPressed: _loadData,
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
            const Icon(Icons.shield_rounded, size: 80, color: Colors.cyan),
            const SizedBox(height: 10),
            const Text(
              'Datos Sensibles Almacenados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              '(Se borrarán si recibes la notificación de wipe_data)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (_sensitiveData.isEmpty)
              const Card(
                color: Colors.redAccent,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('¡DATOS ELIMINADOS REMOTAMENTE!'),
                ),
              )
            else
              ..._sensitiveData.entries.map((e) => Card(
                    child: ListTile(
                      title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(e.value),
                      leading: const Icon(Icons.vpn_key),
                    ),
                  )),
            const SizedBox(height: 30),
            const Divider(),
            const Text('Tu FCM Token para pruebas:', style: TextStyle(fontWeight: FontWeight.bold)),
            SelectableText(
              _fcmToken ?? 'Obteniendo token...',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
