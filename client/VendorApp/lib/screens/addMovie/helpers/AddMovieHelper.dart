import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendorapp/cubits/addMovie/add_movie_cubit.dart';
import 'package:vendorapp/screens/addMovie/widgets/ImageSourceSheet.dart';

class AddMovieHelper {
  static Future<void> _pickImage(
    BuildContext context,
    ImageSource source,
  ) async {
    final picker = ImagePicker();

    try {
      final XFile? picked = await picker.pickImage(source: source);
      if (picked == null) return;

      final file = File(picked.path);
      context.read<AddMovieCubit>().setImageFile(file);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  static void showImagePickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ImageSourceSheet(
        onCameraTap: () => _pickImage(context, ImageSource.camera),
        onGalleryTap: () => _pickImage(context, ImageSource.gallery),
      ),
    );
  }

  static Future<void> AddShowTime(BuildContext context) async {
    final now = DateTime.now();
    final cubit = context.read<AddMovieCubit>();

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );

    if (time == null) return;

    final DateTime dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    cubit.addShowTime(dateTime);
  }
}
