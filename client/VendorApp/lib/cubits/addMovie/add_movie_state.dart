// lib/cubits/add_movie/add_movie_state.dart
import 'dart:io';

class AddMovieState {
  final String title;
  final String description;
  final String price; // keep as string for the TextFields
  final File? imageFile;
  final List<DateTime> showTimes;

  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  AddMovieState({
    required this.title,
    required this.description,
    required this.price,
    required this.imageFile,
    required this.showTimes,
    required this.isSubmitting,
    required this.isSuccess,
    required this.errorMessage,
  });

  factory AddMovieState.initial() => AddMovieState(
    title: '',
    description: '',
    price: '',
    imageFile: null,
    showTimes: const [],
    isSubmitting: false,
    isSuccess: false,
    errorMessage: null,
  );

  AddMovieState copyWith({
    String? title,
    String? description,
    String? price,
    File? imageFile,
    List<DateTime>? showTimes,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return AddMovieState(
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageFile: imageFile ?? this.imageFile,
      showTimes: showTimes ?? this.showTimes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }
}
