import 'package:flutter/material.dart';

class ProfileIconButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String? imageUrl; // Made nullable

  const ProfileIconButton({
    super.key,
    this.onTap,
    this.imageUrl, // Removed the hardcoded default URL
  });

  @override
  Widget build(BuildContext context) {
    // Check if a valid URL was actually passed
    final bool hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.withOpacity(0.2), // Adjusted for older SDK compatibility if needed
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          // Only load the NetworkImage if a URL is provided
          image: hasImage
              ? DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          alignment: Alignment.center, // Ensures the Icon is centered
          children: [
            // 1. THE PLACEHOLDER ICON (Shows when there is no image)
            if (!hasImage)
              const Icon(
                Icons.person,
                color: Colors.grey,
                size: 24,
              ),

            // 2. THE STATUS DOT (Green = Connected)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                height: 12,
                width: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50), // Success Green
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}