import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:vendorapp/services/supabase_client.dart';

class ImagesServices {
  static Future<String?> uploadImage(File imageFile) async {
    try {
      final extension = path.extension(imageFile.path);

      // Generate a unique file name based on the current timestamp
      final fileName =
          "movie_${DateTime.now().millisecondsSinceEpoch}$extension";

      // Upload the image to Supabase Storage bucket
      final response = await SupabaseService.client.storage
          .from('movie_images') // Your storage bucket name
          .upload(fileName, imageFile);

      // Get the public URL of the uploaded image
      final imageUrlResponse = SupabaseService.client.storage
          .from('movie_images')
          .getPublicUrl(fileName);

      // Extract the public URL from the response data
      final imageUrl = imageUrlResponse;

      // Return the path starting from '/storage' (exclude the IP and host part)
      final storagePath = imageUrl.split(
        '/storage',
      )[1]; // Get the part after '/storage'

      return '/storage' +
          storagePath; // Return the storage path part of the URL
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }
}
