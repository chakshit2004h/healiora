import 'package:socket_io_client/socket_io_client.dart' as IO;

class AmbulanceService {
  late IO.Socket socket;
  final String patientId;

  AmbulanceService(this.patientId) {
    socket = IO.io(
      'http://localhost:8000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({"userId": patientId, "role": "patient"})
          .disableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      print("✅ Connected to ambulance service");
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

    socket.connect();
  }

  void updateLocation(double lat, double lng) {
    socket.emit("update_location", {
      "patient_id": patientId,
      "latitude": lat,
      "longitude": lng,
    });
  }

  void requestAmbulance(Map<String, dynamic> emergencyDetails, {double? lat, double? lng}) {
    socket.emit("ambulance_request", {
      "patient_id": patientId,
      if (lat != null) "latitude": lat,
      if (lng != null) "longitude": lng,
      "emergency_details": emergencyDetails,
      "timestamp": DateTime.now().toIso8601String(),
    });
  }
}
