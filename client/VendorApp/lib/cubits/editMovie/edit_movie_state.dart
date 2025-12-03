import 'dart:io';

class EditMovieState {
  final String title;
  final String description;
  final String price; // as text for TextField
  final File? imageFile; // new image if user picks
  final List<DateTime> showTimes;

  final bool isLoadingTimes;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  const EditMovieState({
    required this.title,
    required this.description,
    required this.price,
    required this.imageFile,
    required this.showTimes,
    required this.isLoadingTimes,
    required this.isSubmitting,
    required this.isSuccess,
    required this.errorMessage,
  });

  factory EditMovieState.initial() {
    return const EditMovieState(
      title: '',
      description: '',
      price: '',
      imageFile: null,
      showTimes: [],
      isLoadingTimes: false,
      isSubmitting: false,
      isSuccess: false,
      errorMessage: null,
    );
  }

  EditMovieState copyWith({
    String? title,
    String? description,
    String? price,
    File? imageFile,
    List<DateTime>? showTimes,
    bool? isLoadingTimes,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return EditMovieState(
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageFile: imageFile ?? this.imageFile,
      showTimes: showTimes ?? this.showTimes,
      isLoadingTimes: isLoadingTimes ?? this.isLoadingTimes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }
}
