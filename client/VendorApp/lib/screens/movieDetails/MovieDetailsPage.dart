import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendorapp/constants/AppColors.dart';
import 'package:vendorapp/cubits/movieDetails/MovieDetailsState.dart';
import 'package:vendorapp/cubits/movieDetails/movieDetailsCubit.dart';
import 'package:vendorapp/screens/movieDetails/widgets/MovieDetailsBody.dart';

class MovieDetailsPage extends StatefulWidget {
  final String movieId;

  const MovieDetailsPage({Key? key, required this.movieId}) : super(key: key);

  static const routeName = '/movie-details';

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<MovieDetailsCubit>().loadMovie(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
