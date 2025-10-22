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

    socket.on("connect_error", (err) {
      print("❌ Socket connect_error: $err");
    });
    socket.on("error", (err) {
      print("❌ Socket error: $err");
    });
    socket.on("connect_timeout", (err) {
      print("⚠️ Socket connect_timeout: $err");
    });
    socket.on("reconnect_attempt", (attempt) {
      print("↩️ Socket reconnect_attempt #$attempt");
    });
    socket.on("reconnect", (n) {
      print("✅ Socket reconnected ($n)");
    });
    socket.on("reconnect_error", (err) {
      print("❌ Socket reconnect_error: $err");
    });
    socket.on("reconnect_failed", (_) {
      print("❌ Socket reconnect_failed");
    });

    socket.onDisconnect((_) {
      print("❌ $role socket disconnected");
    });
  }

  void on(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }

  // Debug helper: log any incoming event
  void onAny(void Function(String, dynamic) listener) {
    // socket_io_client exposes onAny(event, data)
    // Some versions use: socket.onAny((event, data) { ... })
    try {
      // ignore: invalid_use_of_visible_for_testing_member
      // ignore: deprecated_member_use
      socket.onAny((event, data) {
        listener(event, data);
      });
    } catch (_) {}
  }

  void dispose() {
    socket.dispose();
  }
}
