import 'dart:io';
import 'package:flutter/services.dart'; // For loading assets
import 'package:vendorapp/services/supabase_client.dart'; // Supabase client service
import 'package:uuid/uuid.dart'; // For generating UUIDs

class MovieSeeding {
  static Future<void> seedMovies() async {
    try {
      // Check if the 'movies' table is empty
      final response = await SupabaseService.client
          .from('movies')
          .select()
          .limit(1);

      if (!response.isEmpty) {
        print('Movies table is already seeded. Skipping insertion.');
        return;
      }

      // Your predefined movie data
      final movieList = [
        {
          'title': 'The Dark Knight',
          'description': 'A Batman movie directed by Christopher Nolan.',
          'price': 10.99,
          'seats_number': 47,
          'image':
              "assets/test-images/zarf_tarek.jpg", // Path to the image in assets
        },
        {
          'title': 'Asef Ela El Ez3ag',
          'description': 'A movie full of excitement and action.',
          'price': 12.99,
          'seats_number': 47,
          'image':
              "assets/test-images/asef_ela_el_ez3ag.jpeg", // Path to the image in assets
        },
        {
          'title': 'Elbasha Telmiz',
          'description': 'A comedy film about a teacher in a small town.',
          'price': 9.99,
          'seats_number': 47,
          'image':
              "assets/test-images/elbasha_telmiz.jpg", // Path to the image in assets
        },
        {
          'title': 'Laf Wdwaran',
          'description': 'A thriller that keeps you on the edge of your seat.',
          'price': 14.99,
          'seats_number': 47,
          'image':
              "assets/test-images/laf_wdwaran.jpg", // Path to the image in assets
        },
        {
          'title': 'Kira Walgen',
          'description':
              'A story of a warrior on a mission to save his people.',
          'price': 11.99,
          'seats_number': 47,
          'image':
              "assets/test-images/kera.jpeg", // Path to the image in assets
        },
      ];

      // Insert movie data and upload images
      for (var movie in movieList) {
        // Load the image from assets
        final ByteData data = await rootBundle.load(movie['image'] as String);
        final List<int> bytes = data.buffer.asUint8List();

        // Generate a unique filename for the image
        final fileName = '${Uuid().v4()}.jpg';

        // Create a File from the bytes
        final file = File('${Directory.systemTemp.path}/$fileName');
        await file.writeAsBytes(bytes);

        // Upload the image to Supabase Storage and get the public URL
        final imageUrl = await uploadImageToSupabase(file, fileName);

        if (imageUrl != null) {
          movie['image'] = imageUrl; // Assign the public URL of the image

          // Insert the movie data into the 'movies' table
          final response = await SupabaseService.client.from('movies').insert([
            movie,
          ]);

          if (response != null && response.error != null) {
            print('Error seeding movie: ${response.error!.message}');
          } else {
            print('Movie seeded successfully!');
          }
        } else {
          print('Error uploading image for movie: ${movie['title']}');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to upload image to Supabase Storage and return the public URL
  static Future<String?> uploadImageToSupabase(
    File imageFile,
    String fileName,
  ) async {
    try {
      // Upload the image to Supabase storage
      final response = await SupabaseService.client.storage
          .from('movie_images') // Your storage bucket name
          .upload(fileName, imageFile);

      // if (response.error != null) {
      //   throw Exception('Error uploading image: ${response.error!.message}');
      // }

      // Get the public URL of the uploaded image
      final imageUrlResponse = SupabaseService.client.storage
          .from('movie_images')
          .getPublicUrl(fileName);

      print(response);
      print(imageUrlResponse);

      // if (imageUrlResponse.error != null) {
      //   throw Exception(
      //     'Error retrieving public URL: ${imageUrlResponse.error!.message}',
      //   );
      // }

      // Extract and return the public URL
      final imageUrl = imageUrlResponse;
      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }
}
