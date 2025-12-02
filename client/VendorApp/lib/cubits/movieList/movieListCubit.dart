import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendorapp/cubits/movieList/movieListState.dart';
import 'package:vendorapp/services/supabase_client.dart';
import '../../models/Movie.dart';

class Movielistcubit extends Cubit<Movieliststate> {
  Movielistcubit() : super(Movieliststate.initial());

  Future<void> fetchMovies({String? search}) async {
    final searchTerm = search ?? state.searchName;

    try {
      emit(
        Movieliststate(
          movies: state.movies,
          isLoading: true,
          searchName: searchTerm,
        ),
      );

      var query = SupabaseService.client.from('movies').select();

      if (searchTerm != null && searchTerm.trim().isNotEmpty) {
        query = query.ilike('title', '%$searchTerm%');
      }

      final List<dynamic> response = await query;

      final movieList = response
          .map<Movie>(
            (movieData) => Movie.fromMap(movieData as Map<String, dynamic>),
          )
          .toList();

      print(response);

      emit(
        Movieliststate(
          movies: movieList,
          isLoading: false,
          searchName: searchTerm,
        ),
      );
    } catch (e, st) {
      print("Error fetching movies: $e");
      print(st);
      emit(
        Movieliststate(movies: [], isLoading: false, searchName: searchTerm),
      );
    }
  }

  void setSearchText(String value) {
    emit(
      Movieliststate(
        movies: state.movies,
        isLoading: state.isLoading,
        searchName: value,
      ),
    );
  }
}
