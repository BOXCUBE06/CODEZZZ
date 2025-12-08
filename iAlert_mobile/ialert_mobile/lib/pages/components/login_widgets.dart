import 'package:flutter/material.dart';

// --- COMPONENT 1: The Modern Input Field ---
class ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Color activeColor;
  final bool isPassword;
  final bool isEmail;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final String? Function(String?)? validator;

  const ModernTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.activeColor,
    this.isPassword = false,
    this.isEmail = false,
    this.obscureText = false,
    this.onToggleVisibility,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      style: const TextStyle(fontWeight: FontWeight.w500),
      cursorColor: activeColor,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        prefixIcon: Icon(icon, color: activeColor),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        // Default Border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        // Active Border (Themed)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: activeColor, width: 2),
        ),
        // Error Styles
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red[100]!, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        floatingLabelStyle: TextStyle(color: activeColor),
      ),
      validator: validator,
    );
  }
}

// --- COMPONENT 2: The Primary Action Button ---
// --- COMPONENT 2: The Primary Action Button ---
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color color;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isLoading,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          // UPDATED: withValues instead of withOpacity
          shadowColor: color.withValues(alpha: 0.4),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                text.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }
}

// --- COMPONENT 3: The Role Toggle Switch ---
class RoleToggleSwitch extends StatelessWidget {
  final String activeRole;
  final Function(String) onRoleChanged;
  final Color activeColor;

  const RoleToggleSwitch({
    super.key,
    required this.activeRole,
    required this.onRoleChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildToggleItem('Student', 'student'),
          _buildToggleItem('Responder', 'responder'),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, String value) {
    final isSelected = activeRole == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onRoleChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            // UPDATED: withValues instead of withOpacity
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? activeColor : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}