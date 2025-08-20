import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AmbulanceDoctorService {
  final String doctorId;
  final String role;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  late IO.Socket socket;

  AmbulanceDoctorService(this.doctorId, this.role);

  Future<void> init() async {
    // Read token from storage
    final token = await storage.read(key: "token");

    socket = IO.io("https://healiorabackend.rawcode.online", {
      "transports": ["websocket"],
      "query": {
        "user_id": doctorId,
        "role": role,
        "token": token, // ✅ sending token
      },
    });

    socket.connect();

    socket.onConnect((_) {
      print("✅ Connected to ambulance service as $role ($doctorId)");
    });

    socket.onDisconnect((_) {
      print("❌ $role socket disconnected");
    });
  }

  void on(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }

  void dispose() {
    socket.dispose();
  }
}
