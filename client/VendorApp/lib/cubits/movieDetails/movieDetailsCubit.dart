import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vendorapp/cubits/movieDetails/MovieDetailsState.dart';
import 'package:vendorapp/models/MovieDetails.dart';
import 'package:vendorapp/models/TimeShow.dart';
import 'package:vendorapp/services/notification_service.dart';
import 'package:vendorapp/services/supabase_client.dart';

class MovieDetailsCubit extends Cubit<MovieDetailsState> {
  MovieDetailsCubit() : super(MovieDetailsState.initial());

  RealtimeChannel? _ticketChannel; // Channel for tickets table updates

  @override
  Future<void> close() {
    _ticketChannel?.unsubscribe();
    return super.close();
  }

  Future<void> loadMovie(String movieId) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      final movieRes = await SupabaseService.client
          .from('movies')
          .select()
          .eq('id', movieId)
          .maybeSingle();

      if (movieRes == null) {
        emit(state.copyWith(isLoading: false, errorMessage: 'Movie not found'));
        return;
      }

      final movie = MovieDetails.fromMap(movieRes);

      final timesRes = await SupabaseService.client
          .from('timeshows')
          .select()
          .eq('mid', movieId);

      final timeShows = (timesRes as List)
          .map((row) => TimeShow.fromMap(row as Map<String, dynamic>))
          .toList();

      TimeShow? firstTimeShow;
      Set<int> reservedSeats = <int>{};

      if (timeShows.isNotEmpty) {
        firstTimeShow = timeShows.first;
        reservedSeats = await _loadReservedSeats(firstTimeShow.id);

        _subscribeToTickets(firstTimeShow.id); // Subscribe to ticket bookings
      }

      emit(
        state.copyWith(
          isLoading: false,
          movie: movie,
          timeShows: timeShows,
          selectedTimeShow: firstTimeShow,
          selectedSeats: <int>{},
          reservedSeats: reservedSeats,
        ),
      );
    } catch (e, st) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error loading movie details',
        ),
      );
    }
  }

  Future<Set<int>> _loadReservedSeats(String timeShowId) async {
    final res = await SupabaseService.client
        .from('reservations')
        .select('seat')
        .eq('tid', timeShowId);

    final list = res as List;
    return list.map<int>((row) => int.parse(row['seat'] as String)).toSet();
  }

  /// Subscribe to INSERT/DELETE on the tickets table (when a ticket is booked)
  void _subscribeToTickets(String timeShowId) {
    _ticketChannel
        ?.unsubscribe(); // Unsubscribe from previous channel if it exists

    final client = SupabaseService.client;

    _ticketChannel = client.channel('tickets_tid_$timeShowId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'tickets',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'tid',
          value: timeShowId,
        ),
        callback: (payload) async {
          final ticketSeats =
              payload.newRecord['seats'] as List; // List of booked seats

          final movieRes = await SupabaseService.client
              .from('movies')
              .select('title')
              .eq('id', state.movie!.id)
              .maybeSingle();

          final movieName = movieRes?['title'] ?? 'Unknown Movie';

          final showtimeRes = await SupabaseService.client
              .from('timeshows')
              .select('time')
              .eq('id', timeShowId)
              .maybeSingle();

          final showtime = showtimeRes?['time'];
          final formattedShowtime = showtime != null
              ? DateTime.parse(showtime).toLocal().toString()
              : 'Unknown Time';

          final seatList = ticketSeats.join(
            ", ",
          ); // Create seat list as a string

          // Show notification with movie name, booked seats, and showtime
          NotificationService.showNotification(
            body:
                "Seats $seatList have been booked for the movie '$movieName' at $formattedShowtime.",
            title: "New Ticket Booked",
            id: Random().nextInt(9999),
          );

          // Update the reserved seats in the state
          final reservedSeats = await _loadReservedSeats(timeShowId);
          emit(state.copyWith(reservedSeats: reservedSeats));
        },
      )
      ..subscribe();
  }

  // Change show time selection
  Future<void> changeShowTime(TimeShow? ts) async {
    if (ts == null) return;
    if (ts == state.selectedTimeShow) return;

    emit(state.copyWith(selectedTimeShow: ts, selectedSeats: <int>{}));

    final reserved = await _loadReservedSeats(ts.id);
    _subscribeToTickets(ts.id); // Subscribe to new time show

    emit(state.copyWith(reservedSeats: reserved));
  }

  // Toggle the seat selection for the user
  void toggleSeat(int index) {
    if (state.reservedSeats.contains(index)) return; // can't select reserved

    final newSet = Set<int>.from(state.selectedSeats);
    if (newSet.contains(index)) {
      newSet.remove(index);
    } else {
      newSet.add(index);
    }
    emit(state.copyWith(selectedSeats: newSet));
  }
}
