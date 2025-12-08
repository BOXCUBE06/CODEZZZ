import 'package:flutter/material.dart';

class CategoryGrid extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  // Static data for icons - UPDATED
  final Map<String, IconData> _categoryIcons = const {
    'Medical': Icons.medical_services_outlined,
    'Fire': Icons.local_fire_department_outlined,
    'Harassment': Icons.people_outline, // New: Using people icon
    'Accident': Icons.car_crash_outlined, // New: Using crash icon
    'Natural Disaster': Icons.cloud_off_outlined, // New: Using cloud/disaster icon
    'Other': Icons.help_outline,
  };

  const CategoryGrid({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: _categoryIcons.length,
      itemBuilder: (context, index) {
        String key = _categoryIcons.keys.elementAt(index);
        bool isSelected = selectedCategory == key;

        return InkWell(
          onTap: () => onCategorySelected(key),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue[50] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _categoryIcons[key],
                  size: 32,
                  color: isSelected ? Colors.blue : Colors.grey[600],
                ),
                const SizedBox(height: 8),
                Text(
                  key,
                  textAlign: TextAlign.center, // Added alignment for longer category names
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blue[900] : Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}