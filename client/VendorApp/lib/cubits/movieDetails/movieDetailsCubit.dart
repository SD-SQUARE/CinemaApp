import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 👈 important
import 'package:vendorapp/cubits/movieDetails/MovieDetailsState.dart';
import 'package:vendorapp/models/MovieDetails.dart';
import 'package:vendorapp/models/TimeShow.dart';
import 'package:vendorapp/services/supabase_client.dart';

class MovieDetailsCubit extends Cubit<MovieDetailsState> {
  MovieDetailsCubit() : super(MovieDetailsState.initial());

  RealtimeChannel? _reservationChannel; // 👈 keep channel reference

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
    } catch (e, st) {
      print('Error loading movie details: $e');
      print(st);
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

  /// subscribe to INSERT/DELETE on reservations for this timeshow
  void _subscribeToReservations(String timeShowId) {
    // cancel previous channel if exists
    _reservationChannel?.unsubscribe();

    final client = SupabaseService.client;

    _reservationChannel = client.channel('reservations_tid_$timeShowId')
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
          emit(state.copyWith(reservedSeats: seats));
        },
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: 'reservations',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'tid',
          value: timeShowId,
        ),
        callback: (payload) async {
          final seats = await _loadReservedSeats(timeShowId);
          emit(state.copyWith(reservedSeats: seats));
        },
      )
      ..subscribe();
  }

  /// when user changes show time from dropdown
  Future<void> changeShowTime(TimeShow? ts) async {
    if (ts == null) return;
    if (ts == state.selectedTimeShow) return; // optional: no-op if same

    // 1) update selected show time & clear selected seats
    emit(
      state.copyWith(
        selectedTimeShow: ts,
        selectedSeats: <int>{},
        // ❌ DO NOT touch isLoading here
      ),
    );

    // 2) load reserved seats for this timeshow
    final reserved = await _loadReservedSeats(ts.id);
    _subscribeToReservations(ts.id); // listen to new timeshow

    // 3) update only reservedSeats
    emit(
      state.copyWith(
        reservedSeats: reserved,
        // keep selectedTimeShow, selectedSeats as they are
      ),
    );
  }

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
