import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../../providers/student_provider.dart';

class StudentMapPage extends StatefulWidget {
  const StudentMapPage({super.key});

  @override
  State<StudentMapPage> createState() => _StudentMapPageState();
}

class _StudentMapPageState extends State<StudentMapPage> {
  final MapController _mapController = MapController();
  
  LatLng? _myLocation;
  List<Marker> _responderMarkers = [];
  Timer? _pollingTimer;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _locateMe();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _locateMe() async {
    try {
      Position pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _myLocation = LatLng(pos.latitude, pos.longitude);
        });
        if (_isInit) {
          _mapController.move(_myLocation!, 16.0);
          _isInit = false;
        }
      }
    } catch (e) {
      print("GPS Error: $e");
    }
  }

  void _startPolling() {
    _fetchResponders();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchResponders());
  }

  Future<void> _fetchResponders() async {
    try {
      final service = context.read<StudentProvider>().studentService;
      final data = await service.getActiveResponders();

      if (!mounted) return;

      final newMarkers = data.map((r) {
        final lat = double.parse(r['lat'].toString());
        final lng = double.parse(r['lng'].toString());

        return Marker(
          point: LatLng(lat, lng),
          width: 60,
          height: 60,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, spreadRadius: 2)
                  ],
                ),
                child: const Icon(Icons.security, color: Colors.blue, size: 24),
              ),
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  r['position'], 
                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList();

      setState(() {
        _responderMarkers = newMarkers;
      });
    } catch (e) {
      print("Map Update Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // 1. REMOVED BACK BUTTON
      ),
      body: Stack(
        children: [
          // FULL SCREEN MAP
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(16.7208, 121.6912),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ialert.app',
              ),
              MarkerLayer(markers: _responderMarkers),
              
              if (_myLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _myLocation!,
                      width: 50,
                      height: 50,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.withOpacity(0.2),
                            ),
                          ),
                          const Icon(Icons.my_location, color: Colors.red, size: 30),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // SAFETY DASHBOARD (Top Card)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Icon(Icons.radar, color: Colors.blue, size: 28),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Live Safety Monitor",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${_responderMarkers.length} Responders Nearby",
                            style: TextStyle(
                              color: _responderMarkers.isEmpty ? Colors.grey : Colors.green[700], 
                              fontSize: 12, 
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. RECENTER BUTTON (Raised Higher)
          Positioned(
            bottom: 150, // <--- CHANGED: Raised to avoid Nav Bar (Standard nav is ~80px)
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              child: const Icon(Icons.gps_fixed, color: Colors.black87),
              onPressed: () {
                _locateMe();
                _fetchResponders();
              },
            ),
          ),
        ],
      ),
    );
  }
}