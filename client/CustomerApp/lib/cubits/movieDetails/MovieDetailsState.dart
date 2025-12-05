import 'package:customerapp/models/MovieDetails.dart';
import 'package:customerapp/models/TimeShow.dart';

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

  // booking
  final bool isBooking;
  final bool bookingSuccess;
  final String? bookingErrorMessage;

  const MovieDetailsState({
    required this.isLoading,
    required this.movie,
    required this.errorMessage,
    required this.timeShows,
    required this.selectedTimeShow,
    required this.selectedSeats,
    required this.reservedSeats,
    required this.isBooking,
    required this.bookingSuccess,
    this.bookingErrorMessage,
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
      isBooking: false,
      bookingSuccess: false,
      bookingErrorMessage: null,
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
    bool? isBooking,
    bool? bookingSuccess,
    String? bookingErrorMessage,
  }) {
    return MovieDetailsState(
      isLoading: isLoading ?? this.isLoading,
      movie: movie ?? this.movie,
      errorMessage: errorMessage,
      timeShows: timeShows ?? this.timeShows,
      selectedTimeShow: selectedTimeShow ?? this.selectedTimeShow,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      reservedSeats: reservedSeats ?? this.reservedSeats,
      isBooking: isBooking ?? this.isBooking,
      bookingSuccess: bookingSuccess ?? this.bookingSuccess,
      bookingErrorMessage: bookingErrorMessage,
    );
  }
}
