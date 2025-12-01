import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendorapp/cubits/movieList/movieListCubit.dart';
import 'package:vendorapp/cubits/movieList/movieListState.dart';
import 'package:vendorapp/screens/movieList/widgets/MovieItem.dart';

class MovieListPage extends StatefulWidget {
  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  @override
  void initState() {
    super.initState();
    context.read<Movielistcubit>().fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Movielistcubit, Movieliststate>(
      builder: (context, state) {
        if (state.isLoading) {
          return Scaffold(
            appBar: AppBar(title: Text('Movies List')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text('Movies List')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (query) {
                    context.read<Movielistcubit>().updateSearchQuery(query);
                  },
                  decoration: InputDecoration(
                    hintText: "Search for a movie...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: state.movies.length,
                  itemBuilder: (context, index) {
                    final movie = state.movies[index];
                    return MovieItem(movie: movie);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
