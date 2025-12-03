import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendorapp/cubits/editMovie/edit_movie_state.dart';
import 'package:vendorapp/models/Movie.dart';
import 'package:vendorapp/services/ImagesServices.dart';
import 'package:vendorapp/services/supabase_client.dart';

class EditMovieCubit extends Cubit<EditMovieState> {
  final Movie movie;

  EditMovieCubit({required this.movie}) : super(EditMovieState.initial()) {
    _initFromMovie();
    _loadShowTimes();
  }

  // ---------- INIT WITH MOVIE DATA ----------
  void _initFromMovie() {
    emit(
      state.copyWith(
        title: movie.title,
        description: movie.description,
        price: movie.price.toString(),
        isSuccess: false,
        errorMessage: null,
      ),
    );
  }

  Future<void> _loadShowTimes() async {
    emit(state.copyWith(isLoadingTimes: true));

    try {
      final res = await SupabaseService.client
          .from('timeshows')
          .select('time')
          .eq('mid', movie.id);

      final list = (res as List).map<DateTime>((row) {
        final iso = row['time'] as String;
        return DateTime.parse(iso).toLocal();
      }).toList();

      emit(state.copyWith(showTimes: list, isLoadingTimes: false));
    } catch (e, st) {
      print('Error loading showtimes for edit: $e');
      print(st);
      emit(
        state.copyWith(
          isLoadingTimes: false,
          errorMessage: 'Error loading showtimes',
        ),
      );
    }
  }

  // ---------- FIELD UPDATERS ----------
  void updateTitle(String value) {
    emit(state.copyWith(title: value, isSuccess: false, errorMessage: null));
  }

  void updateDescription(String value) {
    emit(
      state.copyWith(description: value, isSuccess: false, errorMessage: null),
    );
  }

  void updatePrice(String value) {
    emit(state.copyWith(price: value, isSuccess: false, errorMessage: null));
  }

  void setImageFile(File file) {
    emit(state.copyWith(imageFile: file, isSuccess: false, errorMessage: null));
  }

  void addShowTime(DateTime dt) {
    final list = List<DateTime>.from(state.showTimes)..add(dt);
    emit(state.copyWith(showTimes: list, isSuccess: false, errorMessage: null));
  }

  void removeShowTimeAt(int index) {
    final list = List<DateTime>.from(state.showTimes)..removeAt(index);
    emit(state.copyWith(showTimes: list, isSuccess: false, errorMessage: null));
  }

  // ---------- SUBMIT EDIT ----------
  Future<void> submit() async {
    print('EDIT MOVIE ID: ${movie.id}');
    print(state.title);
    print(state.description);
    print(state.price);
    print(state.imageFile);
    print(state.showTimes);

    // Basic validations
    if (state.title.trim().isEmpty ||
        state.description.trim().isEmpty ||
        state.price.trim().isEmpty ||
        state.showTimes.isEmpty) {
      emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: false,
          errorMessage:
              'Please fill all fields and add at least one show time.',
        ),
      );
      return;
    }

    final priceValue = double.tryParse(state.price.trim()) ?? 0.0;

    print(priceValue);
    if (priceValue == 0.0) {
      emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: false,
          errorMessage: 'Price must be a valid number.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(isSubmitting: true, isSuccess: false, errorMessage: null),
    );

    try {
      // 1) Build update data
      final Map<String, dynamic> updateData = {
        'title': state.title.trim(),
        'description': state.description.trim(),
        'price': priceValue,
      };

      // 2) If user chose a new image
      if (state.imageFile != null) {
        final imageUrl = await ImagesServices.uploadImage(state.imageFile!);
        if (imageUrl == null) {
          throw Exception('Image upload failed');
        }
        updateData['image'] = imageUrl;
      }

      // 3) Update movie row
      await SupabaseService.client
          .from('movies')
          .update(updateData)
          .eq('id', movie.id);

      // 4) Replace showtimes
      await SupabaseService.client
          .from('timeshows')
          .delete()
          .eq('mid', movie.id);

      for (final dt in state.showTimes) {
        await SupabaseService.client.from('timeshows').insert({
          'mid': movie.id,
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
    } catch (e, st) {
      print('Error editing movie: $e');
      print(st);
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
