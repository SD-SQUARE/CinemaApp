import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:vendorapp/services/supabase_client.dart';

class ImagesServices {
  static Future<String?> uploadImage(File imageFile) async {
    try {
      final extension = path.extension(imageFile.path);

      // final fileName = path.basename(imageFile.path);
      final fileName =
          "movie_${DateTime.now().millisecondsSinceEpoch}$extension";

      // Upload the image to Supabase Storage bucket
      final response = await SupabaseService.client.storage
          .from('movie_images') // Your storage bucket name
          .upload(fileName, imageFile);

      print("error ---> ");
      print(response);

      // Check if the response contains an error
      // if (response == imageFile) {
      //   throw Exception('Error uploading image: ${response}');
      // }

      // Get the public URL of the uploaded image
      final imageUrlResponse = SupabaseService.client.storage
          .from('movie_images')
          .getPublicUrl(fileName);

      // Extract the public URL from the response data
      final imageUrl = imageUrlResponse; // 'publicURL' is the correct key

      return imageUrl; // Return the public URL of the uploaded image
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }
}
