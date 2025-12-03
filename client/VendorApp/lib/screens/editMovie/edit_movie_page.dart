import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendorapp/constants/AppColors.dart';
import 'package:vendorapp/cubits/editMovie/edit_movie_cubit.dart';
import 'package:vendorapp/cubits/editMovie/edit_movie_state.dart';
import 'package:vendorapp/models/Movie.dart';
import 'package:vendorapp/screens/editMovie/edit_movie_form.dart';

class EditMoviePage extends StatelessWidget {
  const EditMoviePage({Key? key, required this.movie}) : super(key: key);

  static const routeName = '/edit-movie';

  final Movie movie;
  static final _formKey = GlobalKey<FormState>();

  Future<void> _onUpdate(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<EditMovieCubit>();
    await cubit.submit();

    final state = cubit.state;

    if (state.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movie updated successfully')),
      );
      Navigator.pop(context, true);
    } else if (state.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditMovieCubit(movie: movie),
      child: Scaffold(
        backgroundColor: AppColors.secondaryColor,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          title: const Text(
            "Edit Movie",
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<EditMovieCubit, EditMovieState>(
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: EditMovieForm(
                  formKey: _formKey,
                  movie: movie,
                  state: state,
                  onSubmit: () => _onUpdate(context),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
