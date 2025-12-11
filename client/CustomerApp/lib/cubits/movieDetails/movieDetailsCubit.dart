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
  Future<void> close() async {
    _reservationChannel?.unsubscribe();
    
    // Clean up any selected seats when leaving the page
    await _cleanupSelectedSeats();
    
    return super.close();
  }
  
  // Public method to clean up seats when navigating back
  Future<void> cleanupOnNavigateBack() async {
    await _cleanupSelectedSeats();
  }
  
  // Clean up selected seats by deleting their reservations
  // Only deletes reservations that are NOT booked (not in tickets table)
  Future<void> _cleanupSelectedSeats() async {
    if (state.selectedSeats.isEmpty) return;
    
    final timeShow = state.selectedTimeShow;
    if (timeShow == null) return;
    
    try {
      final client = SupabaseService.client;
      final user = client.auth.currentUser;
      
      if (user == null) return;
      
      final cid = await _getOrCreateCustomerId();
      
      // Get all booked seats for this user and timeshow from tickets table
      final ticketsRes = await client
          .from('tickets')
          .select('seats')
          .eq('cid', cid)
          .eq('tid', timeShow.id);

      final ticketsList = ticketsRes as List;
      final bookedSeats = <int>{};
      for (final ticket in ticketsList) {
        final seats = ticket['seats'] as List;
        for (final seat in seats) {
          bookedSeats.add(int.parse(seat as String));
        }
      }

      // Only delete reservations for seats that are NOT booked
      int deletedCount = 0;
      for (final seatIndex in state.selectedSeats) {
        if (!bookedSeats.contains(seatIndex)) {
          print('Deleting reservation for seat $seatIndex');
          await client
              .from('reservations')
              .delete()
              .eq('cid', cid)
              .eq('tid', timeShow.id)
              .eq('seat', seatIndex.toString());
          deletedCount++;
        } else {
          print('Keeping reservation for booked seat $seatIndex');
        }
      }
      
      print('Cleaned up $deletedCount unbooked seats (kept ${bookedSeats.length} booked)');
    } catch (e) {
      print('Error cleaning up selected seats: $e');
      // Don't throw - we're closing anyway
    }
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
  // This includes both temporary reservations and booked tickets
  Future<Set<int>> _loadReservedSeats(String timeShowId) async {
    final client = SupabaseService.client;
    
    // Load temporary reservations
    final reservationsRes = await client
        .from('reservations')
        .select('seat')
        .eq('tid', timeShowId);

    final reservationsList = reservationsRes as List;
    final reservedSeats = reservationsList
        .map<int>((row) => int.parse(row['seat'] as String))
        .toSet();

    // Load booked tickets
    final ticketsRes = await client
        .from('tickets')
        .select('seats')
        .eq('tid', timeShowId);

    final ticketsList = ticketsRes as List;
    for (final ticket in ticketsList) {
      final seats = ticket['seats'] as List;
      for (final seat in seats) {
        reservedSeats.add(int.parse(seat as String));
      }
    }

    return reservedSeats;
  }

  Future<void> toggleSeat(int index) async {
    final client = SupabaseService.client;
    final movie = state.movie;
    final timeShow = state.selectedTimeShow;

    if (movie == null || timeShow == null) {
      return;
    }

    // Check if user is authenticated
    final user = client.auth.currentUser;
    if (user == null) {
      emit(
        state.copyWith(
          errorMessage: 'You must be logged in to select seats',
        ),
      );
      return;
    }

    try {
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

        // Delete only the specific seat being deselected
        print('Deleting reservation: cid=$cid, tid=${timeShow.id}, seat=$index');
        final deleteResult = await client
            .from('reservations')
            .delete()
            .eq('cid', cid)
            .eq('tid', timeShow.id)
            .eq('seat', index.toString());
        print('Delete result: $deleteResult');

        // Reload reserved seats to ensure consistency
        // This is needed because Supabase real-time DELETE events might not be enabled
        final updatedReservedSeats = await _loadReservedSeats(timeShow.id);
        final finalReservedSeats = updatedReservedSeats.difference(newSet);

        // Emit the updated state with the new selected seats and reserved seats
        emit(
          state.copyWith(
            selectedSeats: newSet,
            reservedSeats: finalReservedSeats,
          ),
        );
      } else {
        // If the seat was not selected, select it (add to the selected set)
        newSet.add(index);

        // Insert only the newly selected seat into the reservation table
        await client.from('reservations').insert({
          'cid': cid,
          'mid': movie.id,
          'tid': timeShow.id,
          'seat': index.toString(),
        });

        // Emit the updated state with the new selected seats
        // Real-time subscription will handle reserved seats updates
        emit(
          state.copyWith(
            selectedSeats: newSet,
          ),
        );
      }
    } on PostgrestException catch (e) {
      // Handle Supabase-specific errors
      print('Database error in toggleSeat: ${e.message}');
      
      // Reload reserved seats to resynchronize state
      if (timeShow != null) {
        try {
          final seats = await _loadReservedSeats(timeShow.id);
          final updatedReservedSeats = seats.difference(state.selectedSeats);
          emit(
            state.copyWith(
              reservedSeats: updatedReservedSeats,
              errorMessage: 'Failed to update seat selection. Please try again.',
            ),
          );
        } catch (reloadError) {
          print('Error reloading reserved seats: $reloadError');
          emit(
            state.copyWith(
              errorMessage: 'Failed to update seat selection. Please try again.',
            ),
          );
        }
      }
    } catch (e) {
      // Handle any other errors
      print('Error in toggleSeat: $e');
      
      // Reload reserved seats to resynchronize state
      if (timeShow != null) {
        try {
          final seats = await _loadReservedSeats(timeShow.id);
          final updatedReservedSeats = seats.difference(state.selectedSeats);
          emit(
            state.copyWith(
              reservedSeats: updatedReservedSeats,
              errorMessage: 'An unexpected error occurred. Please try again.',
            ),
          );
        } catch (reloadError) {
          print('Error reloading reserved seats: $reloadError');
          emit(
            state.copyWith(
              errorMessage: 'An unexpected error occurred. Please try again.',
            ),
          );
        }
      }
    }
  }

  void _subscribeToReservations(String timeShowId) {
    _reservationChannel?.unsubscribe();

    print('Setting up real-time subscription for timeshow: $timeShowId');

    _reservationChannel =
        SupabaseService.client.channel('reservations_tid_$timeShowId')
          ..onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'reservations',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'tid',
              value: timeShowId,
            ),
            callback: (payload) async {
              try {
                print("Real-time event received: ${payload.eventType} - $payload");
                
                final seats = await _loadReservedSeats(timeShowId);
                print("Seats after ${payload.eventType}: $seats");

                // Exclude the currently selected seats from the reservedSeats set
                final updatedReservedSeats = seats.difference(
                  state.selectedSeats,
                );

                print("Updated reserved seats (excluding selected): $updatedReservedSeats");
                emit(state.copyWith(reservedSeats: updatedReservedSeats));
              } catch (e) {
                // Log error but continue processing subsequent events
                print('Error processing ${payload.eventType} event in real-time subscription: $e');
              }
            },
          )
          ..subscribe((status, error) {
            print('Subscription status: $status');
            if (error != null) {
              print('Subscription error: $error');
            }
          });
  }

  // Change show time selection
  Future<void> changeShowTime(TimeShow? ts) async {
    if (ts == null || ts == state.selectedTimeShow) return;

    print('Changing showtime from ${state.selectedTimeShow?.id} to ${ts.id}');
    print('Current selected seats: ${state.selectedSeats}');

    // Clean up selected seats from the previous showtime before switching
    await _cleanupSelectedSeats();

    // Load reserved seats for the new timeslot
    final reserved = await _loadReservedSeats(ts.id);
    
    // Subscribe to the new timeshow's real-time updates
    _subscribeToReservations(ts.id);

    // Emit the complete new state in one go to avoid race conditions
    emit(state.copyWith(
      selectedTimeShow: ts,
      selectedSeats: <int>{}, // Clear selected seats
      reservedSeats: reserved, // Set new reserved seats
    ));

    print('Changed to showtime ${ts.id}');
    print('New reserved seats: $reserved');
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

      // Keep reservations in the table - they represent booked seats
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
