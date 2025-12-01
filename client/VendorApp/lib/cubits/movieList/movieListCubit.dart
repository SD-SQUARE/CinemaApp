import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendorapp/cubits/movieList/movieListState.dart';
import 'package:vendorapp/services/supabase_client.dart';

import '../../models/Movie.dart';

class Movielistcubit extends Cubit<Movieliststate> {
  Movielistcubit() : super(Movieliststate.initial());

  Future<void> fetchMovies({String? search}) async {
    try {
      // keep the current search text in state
      emit(
        Movieliststate(
          movies: state.movies,
          isLoading: true,
          searchName: search ?? state.searchName,
        ),
      );

      var query = SupabaseService.client.from('movies').select();

      if (search != null && search.isNotEmpty) {
        // ilike = case-insensitive LIKE
        query = query.ilike('title', '%$search%');
      }

      final response = await query;

      if (response.isEmpty) {
        emit(
          Movieliststate(
            movies: [],
            isLoading: false,
            searchName: search ?? state.searchName,
          ),
        );
        return;
      }

      final movieList = response
          .map<Movie>((movieData) => Movie.fromMap(movieData))
          .toList();

      emit(
        Movieliststate(
          movies: movieList,
          isLoading: false,
          searchName: search ?? state.searchName,
        ),
      );
    } catch (e) {
      emit(
        Movieliststate(
          movies: [],
          isLoading: false,
          searchName: search ?? state.searchName,
        ),
      );
    }
  }

  void updateSearchQuery(String query) {
    fetchMovies(search: query);
  }
}
