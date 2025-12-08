import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

// 1. IMPORT YOUR PROVIDER
import '../../../providers/student_provider.dart';

// 2. IMPORT YOUR EXISTING UI COMPONENTS
import '../components/form/location_card.dart';
import '../components/form/category_grid.dart';

// 3. IMPORT THE NEW DIALOGS (Ensure these files exist in your folder)
import '../components/form/safety_instructions.dart';
import 'package:frontend_flutter/pages/components/form/assessment.dart';


class StudentFormPage extends StatefulWidget {
  const StudentFormPage({super.key});

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();

  // --- STATE ---
  String _selectedCategory = 'Medical'; // Default
  final TextEditingController _descController = TextEditingController();
  
  // NEW: Track the calculated severity from the dialog
  String _calculatedSeverity = "Pending Assessment"; 
  Color _severityColor = Colors.grey;

  // --- LOCATION STATE ---
  double? _currentLat;
  double? _currentLong;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    
    // Optional: Trigger assessment for default category immediately
    // WidgetsBinding.instance.addPostFrameCallback((_) => _openSeverityAssessment(_selectedCategory));
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  // --- LOGIC 1: Get Location (Kept exactly as you had it) ---
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isLoadingLocation = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentLat = position.latitude;
          _currentLong = position.longitude;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  // --- LOGIC 2: Open Severity Assessment (The "Yes/No" Test) ---
  void _openSeverityAssessment(String category) {
    showDialog(
      context: context,
      barrierDismissible: false, // Force them to answer
      builder: (context) => SeverityAssessmentDialog(
        category: category,
        onScoreCalculated: (result) {
          setState(() {
            _calculatedSeverity = result; // "Mild", "Moderate", or "Severe"
            
            // Set Color visually
            if (result == 'Severe') {
              _severityColor = Colors.red;
            } else if (result == 'Moderate') {
              _severityColor = Colors.orange;
            } else {
              _severityColor = Colors.green;
            }
          });
        },
      ),
    );
  }

  // --- LOGIC 3: Submit Form ---
  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Guard Clause: No Location
    if (_currentLat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Waiting for location..."), backgroundColor: Colors.orange),
      );
      _getCurrentLocation();
      return;
    }

    // Guard Clause: No Severity Assessment
    if (_calculatedSeverity == "Pending Assessment") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please complete the severity assessment first."),
          backgroundColor: Colors.red,
        ),
      );
      // Re-open the dialog for them automatically
      _openSeverityAssessment(_selectedCategory);
      return;
    }

    final provider = context.read<StudentProvider>();
    
    // Send to Backend
    await provider.sendPanicAlert(
      lat: _currentLat!,
      long: _currentLong!,
      category: _selectedCategory,
      severity: _calculatedSeverity, // Sending the calculated result
      description: _descController.text.trim(),
    );

    if (mounted && provider.status == EmergencyStatus.sent) {
      provider.reset();
      
      // Show Safety Instructions (The "What to do" Dialog)
      _showInstructionsPopup(context, _selectedCategory);
    }
  }

  void _showInstructionsPopup(BuildContext context, String category) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SafetyInstructionsDialog(
        category: category,
        onSubmitted: () => Navigator.pop(context), // Close form entirely
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    final isSending = provider.status == EmergencyStatus.sending;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Report Incident", style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      // Submit Button Footer
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            onPressed: (isSending || _isLoadingLocation) ? null : _submitForm,
            child: isSending
                ? const SizedBox(
                    width: 24, height: 24, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text(
                    "SEND EMERGENCY ALERT",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // COMPONENT 1: Location
              _buildTitle("Current Location"),
              const SizedBox(height: 10),
              LocationCard(
                latitude: _currentLat,
                longitude: _currentLong,
                isLoading: _isLoadingLocation,
                onRefresh: _getCurrentLocation,
              ),

              const SizedBox(height: 24),

              // COMPONENT 2: Categories
              _buildTitle("What's happening?"),
              const SizedBox(height: 10),
              CategoryGrid(
                selectedCategory: _selectedCategory,
                onCategorySelected: (val) {
                  setState(() {
                    _selectedCategory = val;
                    // Reset severity when category changes
                    _calculatedSeverity = "Pending Assessment"; 
                    _severityColor = Colors.grey;
                  });
                  // Trigger the Yes/No Questions immediately
                  _openSeverityAssessment(val);
                },
              ),

              const SizedBox(height: 24),

              // COMPONENT 3: Severity Display (Replaced old component with Dynamic Card)
              _buildTitle("Assessed Severity"),
              const SizedBox(height: 10),
              
              InkWell(
                onTap: () => _openSeverityAssessment(_selectedCategory), // Allow retake
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _severityColor.withOpacity(0.1),
                    border: Border.all(color: _severityColor, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.health_and_safety, color: _severityColor, size: 30),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _calculatedSeverity.toUpperCase(),
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold, 
                              color: _severityColor
                            ),
                          ),
                          if (_calculatedSeverity != "Pending Assessment")
                             Text(
                              "Tap to retake assessment",
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                        ],
                      ),
                      const Spacer(),
                      if (_calculatedSeverity == "Pending Assessment")
                        const Icon(Icons.touch_app, color: Colors.grey)
                      else
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // COMPONENT 4: Additional Details
              _buildTitle("Additional Details"),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Describe the situation (optional)...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),

              // Error Display
              if (provider.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(provider.errorMessage!,
                              style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }
}