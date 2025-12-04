import 'package:customerapp/services/supabase_client.dart';
import 'package:flutter/material.dart';

class MoviePoster extends StatelessWidget {
  final String imageUrl;

  const MoviePoster({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Image.network(
            "${SupabaseService.getURL()}${imageUrl}",
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[800],
              child: const Center(
                child: Icon(Icons.movie, color: Colors.white70),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
