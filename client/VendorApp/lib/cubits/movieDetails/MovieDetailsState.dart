import 'package:vendorapp/models/MovieDetails.dart';
import 'package:vendorapp/models/TimeShow.dart';

class MovieDetailsState {
  final bool isLoading;
  final MovieDetails? movie;
  final String? errorMessage;

  // from timeshows table
  final List<TimeShow> timeShows;
  final TimeShow? selectedTimeShow;

  // seats that user chose in UI
  final Set<int> selectedSeats;

  // seats already reserved in DB for the selected time
  final Set<int> reservedSeats;

  const MovieDetailsState({
    required this.isLoading,
    required this.movie,
    required this.errorMessage,
    required this.timeShows,
    required this.selectedTimeShow,
    required this.selectedSeats,
    required this.reservedSeats,
  });

  factory MovieDetailsState.initial() {
    return const MovieDetailsState(
      isLoading: false,
      movie: null,
      errorMessage: null,
      timeShows: [],
      selectedTimeShow: null,
      selectedSeats: <int>{},
      reservedSeats: <int>{},
    );
  }

  MovieDetailsState copyWith({
    bool? isLoading,
    MovieDetails? movie,
    String? errorMessage,
    List<TimeShow>? timeShows,
    TimeShow? selectedTimeShow,
    Set<int>? selectedSeats,
    Set<int>? reservedSeats,
  }) {
    return MovieDetailsState(
      isLoading: isLoading ?? this.isLoading,
      movie: movie ?? this.movie,
      errorMessage: errorMessage,
      timeShows: timeShows ?? this.timeShows,
      selectedTimeShow: selectedTimeShow ?? this.selectedTimeShow,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      reservedSeats: reservedSeats ?? this.reservedSeats,
    );
  }
}
