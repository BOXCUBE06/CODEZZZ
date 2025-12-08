import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend_flutter/models/alert_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../providers/responder_provider.dart';
import 'package:frontend_flutter/pages/components/responder/responder_action_buttons.dart';

class LiveMapWidget extends StatefulWidget {
  final bool showAllAlerts;
  final double? inputLat;
  final double? inputLong;

  const LiveMapWidget({
    super.key,
    required this.showAllAlerts,
    this.inputLat,
    this.inputLong,
  });

  @override
  State<LiveMapWidget> createState() => _LiveMapWidgetState();
}

class _LiveMapWidgetState extends State<LiveMapWidget> {
  final MapController _mapController = MapController();

  // Default fallback location (ISU)
  LatLng _currentLocation = const LatLng(16.7208, 121.6913);

  @override
  void initState() {
    super.initState();

    // 1. Logic: Use Input Location OR Fetch GPS
    if (widget.inputLat != null && widget.inputLong != null) {
      // Student Mode: Use passed coordinates
      _currentLocation = LatLng(widget.inputLat!, widget.inputLong!);
    } else {
      // Responder Mode: Fetch own GPS
      _getCurrentLocation();
    }

    // 2. Fetch Alerts if needed
    if (widget.showAllAlerts) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Ensure ResponderProvider exists in your tree
        context.read<ResponderProvider>().fetchAlerts();
      });
    }
  }

  // 3. Listen for updates from Parent (Student Form)
  @override
  void didUpdateWidget(covariant LiveMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.inputLat != null && widget.inputLong != null) {
      if (widget.inputLat != oldWidget.inputLat ||
          widget.inputLong != oldWidget.inputLong) {
        setState(() {
          _currentLocation = LatLng(widget.inputLat!, widget.inputLong!);
        });
        _mapController.move(_currentLocation, 16.0);
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentLocation, 16.0);
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = [];

    // --- MARKER 1: MY LOCATION ---
    markers.add(
      Marker(
        point: _currentLocation,
        width: 60,
        height: 60,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: const Icon(
                Icons.person_pin_circle,
                color: Colors.blueAccent,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );

    // --- MARKER 2: ALERTS (Only if showAllAlerts is true) ---
    if (widget.showAllAlerts) {
      final provider = context.watch<ResponderProvider>();
      
      for (var alert in provider.alerts) {
        // 1. FILTER: Normalize status to lowercase to ensure matching
        final String status = alert.status.toLowerCase();

        // 2. CHECK: If it is NOT pending and NOT accepted, skip this iteration
        if (status != 'pending' && status != 'accepted') {
          continue; 
        }

        try {
          double lat = (alert.latitude);
          double lng = (alert.longitude);

          markers.add(
            Marker(
              point: LatLng(lat, lng),
              width: 50,
              height: 50,
              child: GestureDetector(
                onTap: () => _showAlertDetails(context, alert),
                child: Icon(
                  Icons.location_on,
                  // Color logic: Red for Pending, Orange for Accepted
                  color: status == 'pending' ? Colors.red : Colors.orange,
                  size: 40,
                ),
              ),
            ),
          );
        } catch (e) {
          debugPrint("Error parsing alert coordinates: ${alert.id}");
        }
      }
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentLocation,
            initialZoom: 16.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.ialert.app',
            ),
            MarkerLayer(markers: markers),
          ],
        ),

        // "Locate Me" Button (Only show if NOT in Student/Input Mode)
        if (widget.inputLat == null)
          Positioned(
            // FIXED: Raised to 120 to avoid being covered by Nav Bar/Legend
            bottom: 170, 
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Color.fromRGBO(33, 150, 243, 1)),
              onPressed: _getCurrentLocation,
            ),
          ),
      ],
    );
  }

  // --- THE EXISTING THING (Alert Details Popup) ---
  void _showAlertDetails(BuildContext context, Alert alert) {
    // Determine Header Color based on Status
    Color headerColor;
    switch (alert.status.toLowerCase()) {
      case 'pending':
        headerColor = Colors.red;
        break;
      case 'accepted':
        headerColor = Colors.orange;
        break;
      case 'arrived':
        headerColor = Colors.purple;
        break;
      case 'resolved':
        headerColor = Colors.green;
        break;
      default:
        headerColor = Colors.grey;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Use full height if needed
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        height: 500, // Increased height to fit everything comfortably
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: headerColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.warning_amber_rounded,
                      color: headerColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // FIX: Use 'type' instead of 'category'
                        alert.type.toUpperCase(), 
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: headerColor,
                              borderRadius: BorderRadius.circular(4)
                            ),
                            child: Text(
                              alert.status.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Severity: ${alert.severity}",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const Divider(height: 30),

            // DETAILS LIST
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _detailRow("Time", alert.time),
                    const SizedBox(height: 12),
                    _detailRow("Coordinates", "${alert.latitude}, ${alert.longitude}"),
                    const SizedBox(height: 12),
                    _detailRow("Student", alert.studentName),
                    const SizedBox(height: 12),
                    if (alert.studentPhone != "N/A")
                       _detailRow("Contact", alert.studentPhone),
                    const SizedBox(height: 12),
                    if (alert.description.isNotEmpty)
                      _detailRow("Description", alert.description),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ACTION BUTTONS (The component we built earlier)
            ResponderActionButtons(
              alert: alert,
              onSuccess: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}