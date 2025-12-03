import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendorapp/constants/AppColors.dart';
import 'package:vendorapp/cubits/addMovie/add_movie_cubit.dart';
import 'package:vendorapp/cubits/addMovie/add_movie_state.dart';
import 'package:vendorapp/screens/addMovie/widgets/add_movie_form.dart';

class AddMoviePage extends StatelessWidget {
  const AddMoviePage({Key? key}) : super(key: key);
  static const routeName = '/add-movie';

  // Form key is immutable → OK in StatelessWidget
  static final _formKey = GlobalKey<FormState>();

  Future<void> _onCreate(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<AddMovieCubit>();
    await cubit.submit();

    final state = cubit.state;

    if (state.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movie created successfully')),
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
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: const Text("Add Movie", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<AddMovieCubit, AddMovieState>(
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: AddMovieForm(
                formKey: _formKey,
                onSubmit: () => _onCreate(context),
              ),
            ),
          );
        },
      ),
    );
  }
}
