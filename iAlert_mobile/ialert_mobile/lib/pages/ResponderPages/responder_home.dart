import 'package:flutter/material.dart';
import 'package:frontend_flutter/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../providers/responder_provider.dart';
import '../../../models/alert_model.dart';

// COMPONENTS
import '../components/alert_card.dart';

import '../components/responder/responder_action_buttons.dart';
import '../components/responder/incident_header.dart';     // NEW
import '../components/responder/reporter_info_card.dart';  // NEW
import '../components/responder/incident_details.dart';   

class ResponderHomeView extends StatefulWidget {
  const ResponderHomeView({super.key});

  @override
  State<ResponderHomeView> createState() => _ResponderHomeViewState();
}

class _ResponderHomeViewState extends State<ResponderHomeView> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      // 1. Get Providers
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final responderProvider = Provider.of<ResponderProvider>(context, listen: false);

      // 2. Set User ID (Critical for "Show Mine" filter)
      final userId = authProvider.user?.id ?? 0;
      responderProvider.setCurrentUserId(userId);

      // 3. Fetch Data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        responderProvider.fetchAlerts();
      });
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResponderProvider>();

    final displayAlerts = provider.filteredAlerts;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          
          // 1. DUTY STATUS TOGGLE
          _buildDutyStatus(provider),


          // 3. FILTER BAR
          _buildFilterBar(context, provider),

          // 4. SHOW MINE TOGGLE (Added Here)
          _buildMineToggle(provider),
          
          Divider(height: 1, color: Colors.grey[200]),

          // 5. MAIN LIST
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => provider.fetchAlerts(refresh: true),
                    child: displayAlerts.isEmpty
                        ? const Center(child: Text("No alerts found."))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: displayAlerts.length,
                            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final alert = displayAlerts[index];
                              return AlertCard(
                                alert: alert,
                                onTap: () => _showAlertDetails(context, alert),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildDutyStatus(ResponderProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("DUTY STATUS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.circle, size: 12, color: provider.isOnline ? Colors.green : Colors.red),
                  const SizedBox(width: 6),
                  Text(
                    provider.isOnline ? "ONLINE" : "OFFLINE",
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold,
                      color: provider.isOnline ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: provider.isOnline,
              activeColor: Colors.green,
              onChanged: (val) => provider.toggleOnlineStatus(val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, ResponderProvider provider) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(context, "Pending", "pending", Colors.red),
          const SizedBox(width: 8),
          _buildFilterChip(context, "Accepted", "accepted", Colors.orange),
          const SizedBox(width: 8),
          _buildFilterChip(context, "Arrived", "arrived", Colors.purple),
          const SizedBox(width: 8),
          _buildFilterChip(context, "Resolved", "resolved", Colors.green),
          const SizedBox(width: 8),
          _buildFilterChip(context, "All History", "all", Colors.blue),
        ],
      ),
    );
  }
  
  // --- NEW: Toggle to show only assigned alerts ---
  Widget _buildMineToggle(ResponderProvider provider) {
    // Hide this toggle if viewing Pending (because Pending alerts aren't assigned yet)
    if (provider.currentFilter == 'pending') return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "Show only my cases", 
            style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500)
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 24, 
            child: Switch(
              value: provider.showOnlyMine,
              activeColor: Colors.blue,
              onChanged: (val) => provider.toggleShowOnlyMine(val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String value, Color color) {
    final provider = context.watch<ResponderProvider>();
    final isSelected = provider.currentFilter == value;
    return ActionChip(
      label: Text(label),
      backgroundColor: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
      labelStyle: TextStyle(color: isSelected ? color : Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12),
      side: BorderSide(color: isSelected ? color : Colors.transparent),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => context.read<ResponderProvider>().setFilter(value),
    );
  }

  // --- DETAILS MODAL ---
  void _showAlertDetails(BuildContext context, Alert alert) {
    Color headerColor;
    switch (alert.status.toLowerCase()) {
      case 'pending': headerColor = Colors.red; break;
      case 'accepted': headerColor = Colors.orange; break;
      case 'arrived': headerColor = Colors.purple; break;
      case 'resolved': headerColor = Colors.green; break;
      default: headerColor = Colors.grey;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    IncidentHeader(type: alert.type, status: alert.status, headerColor: headerColor),
                    const SizedBox(height: 24),
                    ReporterInfoCard(name: alert.studentName, phone: alert.studentPhone),
                    const SizedBox(height: 24),
                    IncidentDetails(description: alert.description, severity: alert.severity, time: alert.time),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ResponderActionButtons(
              alert: alert,
              onSuccess: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}