import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendorapp/cubits/addMovie/add_movie_state.dart';
import 'package:vendorapp/services/supabase_client.dart';
import 'package:vendorapp/services/ImagesServices.dart';

class AddMovieCubit extends Cubit<AddMovieState> {
  AddMovieCubit() : super(AddMovieState.initial());

  void updateTitle(String value) {
    emit(state.copyWith(title: value, errorMessage: null, isSuccess: false));
  }

  void updateDescription(String value) {
    emit(
      state.copyWith(description: value, errorMessage: null, isSuccess: false),
    );
  }

  void updatePrice(String value) {
    emit(state.copyWith(price: value, errorMessage: null, isSuccess: false));
  }

  void setImageFile(File file) {
    emit(state.copyWith(imageFile: file, errorMessage: null, isSuccess: false));
  }

  void addShowTime(DateTime dt) {
    final list = List<DateTime>.from(state.showTimes)..add(dt);
    emit(state.copyWith(showTimes: list, errorMessage: null, isSuccess: false));
  }

  void removeShowTimeAt(int index) {
    final list = List<DateTime>.from(state.showTimes)..removeAt(index);
    emit(state.copyWith(showTimes: list, errorMessage: null, isSuccess: false));
  }

  Future<void> submit() async {
    // Basic validations
    if (state.title.trim().isEmpty ||
        state.description.trim().isEmpty ||
        state.price.trim().isEmpty ||
        state.imageFile == null ||
        state.showTimes.isEmpty) {
      emit(
        state.copyWith(
          errorMessage:
              'Please fill all fields, pick an image, and add at least one show time.',
        ),
      );
      return;
    }

    final priceValue = double.tryParse(state.price.trim());
    if (priceValue == null) {
      emit(state.copyWith(errorMessage: 'Price must be a valid number.'));
      return;
    }

    emit(
      state.copyWith(isSubmitting: true, errorMessage: null, isSuccess: false),
    );

    try {
      // 1) Upload image to storage
      final imageUrl = await ImagesServices.uploadImage(state.imageFile!);

      if (imageUrl == null) {
        throw Exception('Image upload failed');
      }

      // 2) Insert into movies table and get the id
      final movieRes = await SupabaseService.client
          .from('movies')
          .insert({
            'title': state.title.trim(),
            'description': state.description.trim(),
            'price': priceValue,
            'image': imageUrl,
            'seats_number': 47, // or get from UI later
          })
          .select('id')
          .single();

      final movieId = movieRes['id'];

      // 3) Insert timeshows rows
      for (final dt in state.showTimes) {
        var a = await SupabaseService.client.from('timeshows').insert({
          'mid': movieId,
          'time': dt.toUtc().toIso8601String(),
        });
      }

      emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
