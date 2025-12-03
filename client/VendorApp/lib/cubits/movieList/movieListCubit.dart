import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendorapp/cubits/movieList/movieListState.dart';
import 'package:vendorapp/services/supabase_client.dart';
import '../../models/Movie.dart';

class Movielistcubit extends Cubit<Movieliststate> {
  Movielistcubit() : super(Movieliststate.initial());

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
      print("Error fetching movies: $e");
      print(st);
      emit(state.copyWith(movies: [], isLoading: false));
    }
  }

  void setSearchText(String value) {
    emit(state.copyWith(searchName: value));
  }

  Future<void> deleteMovie(String movieId) async {
    try {
      emit(state.copyWith(isLoading: true));

      await SupabaseService.client.from('movies').delete().eq('id', movieId);

      // Refresh list after deletion (keeps current search filter)
      await fetchMovies(search: state.searchName);
    } catch (e, st) {
      print("Error deleting movie: $e");
      print(st);

      emit(state.copyWith(isLoading: false));
    }
  }
}
