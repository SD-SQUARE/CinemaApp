import 'dart:async'; // 👈 IMPORTANT for Timer

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendorapp/constants/AppColors.dart';
import 'package:vendorapp/cubits/movieList/movieListCubit.dart';
import 'package:vendorapp/cubits/movieList/movieListState.dart';
import 'package:vendorapp/screens/editMovie/edit_movie_page.dart';
import 'package:vendorapp/screens/movieList/widgets/MovieItem.dart';

class MovieListPage extends StatefulWidget {
  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<Movielistcubit>().fetchMovies();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<Movielistcubit>().fetchMovies(search: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Movielistcubit, Movieliststate>(
      builder: (context, state) {
        if (state.isLoading && state.movies.isEmpty) {
          // loading first time only
          return Scaffold(
            backgroundColor: AppColors.primaryColor,
            appBar: AppBar(title: const Text('Movies List')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.secondaryColor,
          appBar: AppBar(
            title: Text(
              'Movies List',
              style: TextStyle(color: AppColors.textColor),
            ),
            backgroundColor: AppColors.primaryColor,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    fillColor: AppColors.textColor,
                    filled: true,
                    hintText: "Search for a movie...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textColor),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: LinearProgressIndicator(),
                ),
              Expanded(
                child: state.movies.isEmpty
                    ? const Center(
                        child: Text(
                          "No movies found",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio: 0.65,
                            ),
                        itemCount: state.movies.length,
                        itemBuilder: (context, index) {
                          final movie = state.movies[index];
                          return MovieItem(
                            movie: movie,
                            onDelete: () async {
                              context.read<Movielistcubit>().deleteMovie(
                                movie.id,
                              );
                              // setState(() {
                              //   state.movies.removeAt(index);
                              // });
                            },
                            onEdit: () async {
                              final shouldRefresh = await Navigator.of(context)
                                  .push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditMoviePage(movie: movie),
                                    ),
                                  );

                              if (shouldRefresh == true) {
                                context.read<Movielistcubit>().fetchMovies(
                                  search: context
                                      .read<Movielistcubit>()
                                      .state
                                      .searchName,
                                );
                              }
                            },
                          );
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
