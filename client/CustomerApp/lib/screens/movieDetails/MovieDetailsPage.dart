import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customerapp/constants/AppColors.dart';
import 'package:customerapp/cubits/movieDetails/MovieDetailsState.dart';
import 'package:customerapp/cubits/movieDetails/movieDetailsCubit.dart';
import 'package:customerapp/screens/movieDetails/widgets/MovieDetailsBody.dart';

class MovieDetailsPage extends StatefulWidget {
  final String movieId;

  const MovieDetailsPage({Key? key, required this.movieId}) : super(key: key);

  static const routeName = '/movie-details';

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  late final MovieDetailsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MovieDetailsCubit>();
    _cubit.loadMovie(widget.movieId);
  }

  @override
  void dispose() {
    // Clean up selected seats when leaving the page
    // Use unawaited to avoid blocking dispose
    _cubit.cleanupOnNavigateBack();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _cubit.cleanupOnNavigateBack();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.secondaryColor,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text(
            'Movie details',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocBuilder<MovieDetailsCubit, MovieDetailsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null || state.movie == null) {
              return Center(
                child: Text(
                  state.errorMessage ?? 'Unknown error',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            return MovieDetailsBody(state: state);
          },
        ),
      ),
    );
  }
}
