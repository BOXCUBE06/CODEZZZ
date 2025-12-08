import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../providers/responder_provider.dart';

class ResponderActionButtons extends StatelessWidget {
  final dynamic alert; 
  final VoidCallback onSuccess;

  const ResponderActionButtons({
    super.key, 
    required this.alert, 
    required this.onSuccess
  });

  @override
  Widget build(BuildContext context) {
    final String status = alert.status.toString().trim().toLowerCase();
    
    final double targetLat = double.tryParse(alert.latitude.toString()) ?? 0.0;
    final double targetLng = double.tryParse(alert.longitude.toString()) ?? 0.0;
    final LatLng targetLocation = LatLng(targetLat, targetLng);
    final bool hasValidLocation = targetLat != 0.0 && targetLng != 0.0;

    String buttonText = '';
    Color buttonColor = Colors.grey;
    IconData buttonIcon = Icons.help;
    bool isActionable = true;
    
    Future<void> Function()? action;

    switch (status) {
      case 'pending':
        buttonText = 'ACCEPT ALERT';
        buttonColor = Colors.blue[700]!;
        buttonIcon = Icons.thumb_up;
        action = () => _acceptAlert(context);
        break;
      case 'accepted':
        buttonText = 'I HAVE ARRIVED';
        buttonColor = Colors.orange[800]!;
        buttonIcon = Icons.location_on;
        action = () => _markArrived(context);
        break;
      case 'arrived':
        buttonText = 'RESOLVE INCIDENT';
        buttonColor = Colors.green[700]!;
        buttonIcon = Icons.check_circle;
        action = () => _showResolveConfirmation(context); // Simple confirm
        break;
      default:
        isActionable = false;
        buttonText = 'CASE CLOSED';
        buttonColor = Colors.grey[400]!;
        buttonIcon = Icons.lock;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        
        // --- LOCKED MINIMAP ---
        if (hasValidLocation)
          Container(
            height: 150,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: targetLocation,
                      initialZoom: 16.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none, // Locked
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.ialert.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: targetLocation,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text("Target Location", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // --- PRIMARY BUTTON ---
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: !isActionable ? null : action,
            icon: Icon(buttonIcon, color: Colors.white),
            label: Text(
              buttonText, 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
          ),
        ),
        
        // --- CANCEL BUTTON ---
        if (isActionable) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: TextButton(
              onPressed: () => _showCancelConfirmation(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Cancel Alert (False Alarm)", style: TextStyle(fontSize: 14)),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
        ],
      ],
    );
  }

  // --- ACTIONS ---

  Future<void> _acceptAlert(BuildContext context) async {
    try {
      await context.read<ResponderProvider>().acceptAlert(alert.id);
      if (context.mounted) _showSuccess(context, "Alert Accepted!");
    } catch (e) {
      if (context.mounted) _showError(context, e.toString());
    }
  }

  Future<void> _markArrived(BuildContext context) async {
    try {
      await context.read<ResponderProvider>().markArrived(alert.id);
      if (context.mounted) _showSuccess(context, "Status updated: On Scene");
    } catch (e) {
      if (context.mounted) _showError(context, e.toString());
    }
  }

  // UPDATED: Simple Confirmation Dialog (No Remarks Field)
  Future<void> _showResolveConfirmation(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Resolve Incident?"),
        content: const Text("Are you sure you want to close this case? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              Navigator.pop(ctx); 
              try {
                await context.read<ResponderProvider>().resolveAlert(
                  alert.id, 
                  "Resolved by responder" // Default remark since field is gone
                );
                if (context.mounted) _showSuccess(context, "Case Closed Successfully");
              } catch (e) {
                if (context.mounted) _showError(context, e.toString());
              }
            },
            child: const Text("CONFIRM RESOLVE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel Alert?"),
        content: const Text("Are you sure this is a false alarm? The status will be set to 'Cancelled'."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<ResponderProvider>().cancelAlert(alert.id);
                if (context.mounted) _showSuccess(context, "Alert Cancelled");
              } catch (e) {
                if (context.mounted) _showError(context, e.toString());
              }
            }, 
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
    onSuccess();
  }

  void _showError(BuildContext context, String message) {
    final cleanMsg = message.replaceAll("Exception: ", "");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(cleanMsg), backgroundColor: Colors.red));
  }
}