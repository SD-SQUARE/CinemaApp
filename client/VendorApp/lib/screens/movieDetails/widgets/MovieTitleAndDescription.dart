import 'package:flutter/material.dart';

class MovieTitleAndDescription extends StatelessWidget {
  final String title;
  final String description;

  const MovieTitleAndDescription({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
