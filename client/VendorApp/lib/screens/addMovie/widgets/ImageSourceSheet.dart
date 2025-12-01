import 'package:flutter/material.dart';

class ImageSourceSheet extends StatelessWidget {
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  const ImageSourceSheet({
    Key? key,
    required this.onCameraTap,
    required this.onGalleryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera, color: Colors.white),
            title: const Text(
              "Take Photo",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              onCameraTap();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.white),
            title: const Text(
              "Choose from Gallery",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              onGalleryTap();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
