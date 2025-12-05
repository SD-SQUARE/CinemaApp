import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:customerapp/cubits/movieDetails/MovieDetailsState.dart';
import 'package:customerapp/models/MovieDetails.dart';
import 'package:customerapp/models/TimeShow.dart';
import 'package:customerapp/services/supabase_client.dart';

class MovieDetailsCubit extends Cubit<MovieDetailsState> {
  MovieDetailsCubit() : super(MovieDetailsState.initial());

  RealtimeChannel? _reservationChannel;

  @override
  Future<void> close() {
    _reservationChannel?.unsubscribe();
    return super.close();
  }

  Future<void> loadMovie(String movieId) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      // 1) movie
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

      // 2) time shows
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

        _subscribeToReservations(firstTimeShow.id);
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
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error loading movie details',
        ),
      );
    }
  }

  // Fetch reserved seats for a specific timeshow
  Future<Set<int>> _loadReservedSeats(String timeShowId) async {
    final res = await SupabaseService.client
        .from('reservations')
        .select('seat')
        .eq('tid', timeShowId);

    final list = res as List;
    return list.map<int>((row) => int.parse(row['seat'] as String)).toSet();
  }

  Future<void> toggleSeat(int index) async {
    final client = SupabaseService.client;
    final movie = state.movie;
    final timeShow = state.selectedTimeShow;

    if (movie == null || timeShow == null) {
      return;
    }

    // Get current user ID
    final cid = await _getOrCreateCustomerId();

    // If the seat is reserved, return (can't select it)
    if (state.reservedSeats.contains(index)) {
      return;
    }

    // Create a new set of selected seats based on the current selection
    final newSet = Set<int>.from(state.selectedSeats);

    if (newSet.contains(index)) {
      // If the seat was selected, deselect it (remove from the selected set)
      newSet.remove(index);

      // Delete all reservations for this user and the current timeshow
      await client
          .from('reservations')
          .delete()
          .eq('cid', cid)
          .eq(
            'tid',
            timeShow.id,
          ); // Remove all reservations for this user and time show

      // After deletion, immediately insert the updated selected seats (this triggers the INSERT event)
      await _insertUpdatedReservations(newSet, cid, movie.id, timeShow.id);

      // Insert a dummy seat (50) if no seats are selected
      if (newSet.isEmpty) {
        await _insertDummySeat(cid, movie.id, timeShow.id);
      }

      // Emit the updated state with both the selected and reserved seats
      emit(
        state.copyWith(
          selectedSeats: newSet,
          reservedSeats: await _loadReservedSeats(
            timeShow.id,
          ), // Force a re-fetch of the reserved seats
        ),
      );
    } else {
      // If the seat was not selected, select it (add to the selected set)
      newSet.add(index);

      // Insert the selected seat into the reservation table
      await client.from('reservations').insert({
        'cid': cid,
        'mid': movie.id,
        'tid': timeShow.id,
        'seat': index.toString(),
      });

      // Reload the reserved seats after the insertion to reflect the update
      final reservedSeats = await _loadReservedSeats(timeShow.id);
      final updatedReservedSeats = reservedSeats.difference(newSet);

      // Emit the updated state with both the selected and reserved seats
      emit(
        state.copyWith(
          selectedSeats: newSet,
          reservedSeats: updatedReservedSeats,
        ),
      );
    }
  }

  // Helper function to insert the dummy seat with seat number 50
  Future<void> _insertDummySeat(
    String cid,
    String movieId,
    String timeShowId,
  ) async {
    final client = SupabaseService.client;

    var ran = Random().nextInt(1000) + 50;

    // Insert the dummy seat into the reservation table
    await client.from('reservations').insert({
      'cid': cid,
      'mid': movieId,
      'tid': timeShowId,
      'seat': ran.toString(),
    });

    // Remove the dummy seat after a short delay
    await client
        .from('reservations')
        .delete()
        .eq('seat', ran.toString())
        .eq('cid', cid)
        .eq('tid', timeShowId);
  }

  // Helper function to insert the updated selected seats (after deleting previous reservations)
  Future<void> _insertUpdatedReservations(
    Set<int> selectedSeats,
    String cid,
    String movieId,
    String timeShowId,
  ) async {
    final client = SupabaseService.client;

    // If no selected seats, emit an empty list (or handle it however you need)
    if (selectedSeats.isEmpty) {
      emit(state.copyWith(selectedSeats: {}));
      return;
    }

    // Convert selected seats to a list of seat strings
    final seatStrings = selectedSeats.map((idx) => idx.toString()).toList();

    // Insert the new selected seats into the reservations table
    await client
        .from('reservations')
        .insert(
          seatStrings
              .map(
                (seat) => {
                  'cid': cid,
                  'mid': movieId,
                  'tid': timeShowId,
                  'seat': seat,
                },
              )
              .toList(),
        )
        .onError((error, stackTrace) {
          // Handle any insert errors here
        });

    // Emit the updated reserved seats after inserting
    final reservedSeats = await _loadReservedSeats(timeShowId);
    emit(state.copyWith(reservedSeats: reservedSeats));
  }

  void _subscribeToReservations(String timeShowId) {
    _reservationChannel?.unsubscribe();

    _reservationChannel =
        SupabaseService.client.channel('reservations_tid_$timeShowId')
          ..onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'reservations',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'tid',
              value: timeShowId,
            ),
            callback: (payload) async {

              final seats = await _loadReservedSeats(timeShowId);

              // Exclude the currently selected seats from the reservedSeats set
              final updatedReservedSeats = seats.difference(
                state.selectedSeats,
              );

              emit(state.copyWith(reservedSeats: updatedReservedSeats));
            },
          )
          ..subscribe();
  }

  // Change show time selection
  // TODO delete the seats selected for the show time switch to other show time
  Future<void> changeShowTime(TimeShow? ts) async {
    if (ts == null || ts == state.selectedTimeShow) return;

    emit(state.copyWith(selectedTimeShow: ts, selectedSeats: <int>{}));

    final reserved = await _loadReservedSeats(ts.id);
    _subscribeToReservations(ts.id); // Listen for changes to new timeshow

    emit(state.copyWith(reservedSeats: reserved));
  }

  // Get or create the customer ID for the current user
  Future<String> _getOrCreateCustomerId() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    final uid = user.id;

    final existing = await SupabaseService.client
        .from('customers')
        .select('id')
        .eq('uid', uid)
        .maybeSingle();

    return existing!['id'] as String;
  }

  // Confirm the booking and insert data into the tickets table
  Future<void> bookSelectedSeats() async {
    final movie = state.movie;
    final timeShow = state.selectedTimeShow;
    final seats = state.selectedSeats;

    if (movie == null || timeShow == null || seats.isEmpty) {
      emit(
        state.copyWith(
          bookingErrorMessage: 'Select show time and at least one seat.',
          bookingSuccess: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isBooking: true,
        bookingErrorMessage: null,
        bookingSuccess: false,
      ),
    );

    try {
      final client = SupabaseService.client;
      final cid = await _getOrCreateCustomerId();

      final seatStrings = seats
          .map((idx) => idx.toString())
          .toList(growable: false);
      final totalPrice = movie.price * seatStrings.length;

      // Insert into the tickets table
      await client.from('tickets').insert({
        'cid': cid,
        'mid': movie.id,
        'tid': timeShow.id,
        'seats': seatStrings, // text[] array
        'total_price': totalPrice, // numeric
      });

      final reservedSeats = await _loadReservedSeats(timeShow.id);
      emit(state.copyWith(reservedSeats: reservedSeats));

      emit(
        state.copyWith(
          isBooking: false,
          bookingSuccess: true,
          bookingErrorMessage: null,
          selectedSeats: <int>{}, // Clear selected seats
        ),
      );
    } on PostgrestException catch (e) {
      emit(
        state.copyWith(
          isBooking: false,
          bookingSuccess: false,
          bookingErrorMessage: e.message ?? 'Booking failed.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isBooking: false,
          bookingSuccess: false,
          bookingErrorMessage: 'Booking failed. Please try again.',
        ),
      );
    }
  }
}
