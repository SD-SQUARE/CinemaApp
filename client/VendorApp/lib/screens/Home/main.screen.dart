import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendorapp/constants/AppColors.dart';
import 'package:vendorapp/cubits/addMovie/add_movie_cubit.dart';
import 'package:vendorapp/cubits/movieList/movieListCubit.dart';
import 'package:vendorapp/screens/addMovie/AddMovie.dart';
import 'package:vendorapp/screens/navigationBar/navigationBar.dart';

class MainScreen extends StatelessWidget {
  static const routeName = '/main-screen';

  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const NavigationBarSection(),
          Positioned(
            right: 20.0,
            bottom: 120.0,
            child: FloatingActionButton(
              onPressed: () async {
                final created = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => AddMovieCubit(),
                      child: const AddMoviePage(),
                    ),
                  ),
                );

                if (created == true) {
                  context.read<Movielistcubit>().fetchMovies(
                    search: context.read<Movielistcubit>().state.searchName,
                  );
                }
              },
              child: const Icon(Icons.add, color: AppColors.textColor),
              backgroundColor: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
