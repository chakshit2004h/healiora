import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AmbulanceSocketService {
  final String ambulanceId;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  late IO.Socket socket;

  AmbulanceSocketService(this.ambulanceId, String s);

  Future<void> init() async {
    // Read token from secure storage
    final token = await storage.read(key: "token");

    socket = IO.io("https://healiorabackend.rawcode.online", {
      "transports": ["websocket"],
      "query": {
        "user_id": ambulanceId,
        "role": "ambulance", // ✅ role is ambulance now
        "token": token,
      },
    });

    socket.connect();

    socket.onConnect((_) {
      print("✅ Connected to ambulance service as ambulance ($ambulanceId)");
    });

    socket.onDisconnect((_) {
      print("❌ Ambulance socket disconnected");
    });
  }

  void on(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }

  void dispose() {
    socket.dispose();
  }
}
