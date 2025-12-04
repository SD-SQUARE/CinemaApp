import 'package:customerapp/models/Movie.dart';

class Movieliststate {
  final List<Movie> movies;
  final bool isLoading;
  final String? searchName;

  Movieliststate({
    required this.movies,
    required this.isLoading,
    this.searchName,
  });

  factory Movieliststate.initial() {
    return Movieliststate(movies: [], isLoading: false, searchName: null);
  }

  Movieliststate copyWith({
    List<Movie>? movies,
    bool? isLoading,
    String? searchName,
  }) {
    return Movieliststate(
      movies: movies ?? this.movies,
      isLoading: isLoading ?? this.isLoading,
      searchName: searchName ?? this.searchName,
    );
  }
}
