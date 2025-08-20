import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AmbulanceService {
  late IO.Socket socket;
  final String patientId;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  AmbulanceService(this.patientId);

  Future<void> init() async {
    // Read token from storage
    final token = await storage.read(key: "token");

    socket = IO.io(
      "https://healiorabackend.rawcode.online",
      IO.OptionBuilder()
          .setTransports(["websocket"])
          .setQuery({
        "user_id": patientId,
        "role": "patient",
        "token": token, // ✅ send token
      })
          .build(),
    );

    // Connect once during service creation
    socket.connect();

    socket.onConnect((_) {
      print("✅ Connected to ambulance service as patient: $patientId");
    });

    socket.on("ambulance_request_confirmed", (data) {
      print("📩 Request confirmed: $data");
    });

    socket.on("ambulance_accepted", (data) {
      print("🚑 Ambulance accepted: $data");
    });

    socket.on("ambulance_rejected", (data) {
      print("❌ Ambulance rejected: $data");
    });

    socket.onDisconnect((_) {
      print("❌ Patient socket disconnected");
    });
  }

  /// ✅ now properly defined at class level
  void updateLocation(double lat, double lng) {
    socket.emit("update_location", {
      "patient_id": patientId,
      "latitude": lat,
      "longitude": lng,
    });
  }

  void requestAmbulance(Map<String, dynamic> emergencyDetails,
      {double? lat, double? lng}) {
    print("📤 Sending ambulance request...");
    socket.emit("ambulance_request", {
      "patient_id": patientId,
      if (lat != null) "latitude": lat,
      if (lng != null) "longitude": lng,
      "emergency_details": emergencyDetails,
      "timestamp": DateTime.now().toIso8601String(),
    });
  }

  void dispose() {
    socket.dispose();
  }
}
