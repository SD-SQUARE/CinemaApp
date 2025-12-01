import 'package:vendorapp/models/Movie.dart';

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
}
