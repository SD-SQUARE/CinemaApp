import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:customerapp/cubits/movieList/movieListState.dart';
import 'package:customerapp/services/supabase_client.dart';
import '../../models/Movie.dart';

class Movielistcubit extends Cubit<Movieliststate> {
  Movielistcubit() : super(Movieliststate.initial()) {
    _subscribeToMovies();
  }

  RealtimeChannel? _movieChannel;

  @override
  Future<void> close() {
    _movieChannel?.unsubscribe();
    return super.close();
  }

  void _subscribeToMovies() {
    print('Setting up real-time subscription for movies');

    _movieChannel = SupabaseService.client.channel('movies_realtime')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'movies',
        callback: (payload) async {
          // Reload movies to get the latest data
          await fetchMovies();
        },
      )
      ..subscribe((status, error) {
        if (error != null) {
          print('Movies subscription error: $error');
        }
      });
  }

  Future<void> fetchMovies({String? search}) async {
    final searchTerm = search ?? state.searchName;

    try {
      // set loading true, keep current movies
      emit(state.copyWith(isLoading: true, searchName: searchTerm));

      var query = SupabaseService.client.from('movies').select();

      if (searchTerm != null && searchTerm.trim().isNotEmpty) {
        query = query.ilike('title', '%$searchTerm%');
      }

      final List<dynamic> response = await query.order(
        'createdAt',
        ascending: false,
      );

      final movieList = response
          .map<Movie>(
            (movieData) => Movie.fromMap(movieData as Map<String, dynamic>),
          )
          .toList();

      emit(state.copyWith(movies: movieList, isLoading: false));
    } catch (e, st) {
      emit(state.copyWith(movies: [], isLoading: false));
    }
  }

  void setSearchText(String value) {
    emit(state.copyWith(searchName: value));
  }
}
