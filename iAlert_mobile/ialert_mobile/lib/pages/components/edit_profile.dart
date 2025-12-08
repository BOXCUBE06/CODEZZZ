import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class EditProfileDialog extends StatefulWidget {
  final User user;
  // Pass details dynamically (can be StudentDetails or ResponderDetails)
  final dynamic details; 

  const EditProfileDialog({
    super.key,
    required this.user,
    required this.details,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _positionController; // Responder
  late TextEditingController _departmentController; // Student
  
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State
  String? _selectedYearLevel; // Student
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill data
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '');
    
    // Role specific pre-fill
    if (widget.user.role == 'responder') {
      _positionController = TextEditingController(text: widget.details?.position ?? '');
      _departmentController = TextEditingController();
    } else {
      _positionController = TextEditingController();
      _departmentController = TextEditingController(text: widget.details?.department ?? '');
      _selectedYearLevel = widget.details?.yearLevel?.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<AuthProvider>();
    
    final success = await provider.updateProfile(
      name: _nameController.text,
      phoneNumber: _phoneController.text,
      password: _passwordController.text.isEmpty ? null : _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text.isEmpty ? null : _confirmPasswordController.text,
      
      // Conditional Logic based on Role
      department: widget.user.role == 'student' ? _departmentController.text : null,
      yearLevel: widget.user.role == 'student' ? _selectedYearLevel : null,
      position: widget.user.role == 'responder' ? _positionController.text : null,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Updated Successfully'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? 'Update failed'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = widget.user.role == 'student';

    return AlertDialog(
      title: const Text("Edit Profile"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- COMMON FIELDS ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isEmpty ? "Name is required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone Number", prefixIcon: Icon(Icons.phone)),
              ),
              
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // --- ROLE SPECIFIC FIELDS ---
              if (isStudent) ...[
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(labelText: "Department", prefixIcon: Icon(Icons.school)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedYearLevel,
                  decoration: const InputDecoration(labelText: "Year Level", prefixIcon: Icon(Icons.calendar_today)),
                  items: ['1', '2', '3', '4'].map((y) => DropdownMenuItem(value: y, child: Text("Year $y"))).toList(),
                  onChanged: (val) => setState(() => _selectedYearLevel = val),
                ),
              ],

              if (!isStudent) ...[
                 TextFormField(
                  controller: _positionController,
                  decoration: const InputDecoration(labelText: "Position / Role", prefixIcon: Icon(Icons.badge)),
                ),
              ],

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              
              // --- PASSWORD CHANGE (Optional) ---
              const Text("Change Password (Optional)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "New Password", prefixIcon: Icon(Icons.lock)),
                obscureText: true,
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length < 8) return "Min 8 chars";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: "Confirm Password", prefixIcon: Icon(Icons.lock_outline)),
                obscureText: true,
                validator: (v) {
                  if (_passwordController.text.isNotEmpty && v != _passwordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("CANCEL"),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text("SAVE CHANGES"),
        ),
      ],
    );
  }
}