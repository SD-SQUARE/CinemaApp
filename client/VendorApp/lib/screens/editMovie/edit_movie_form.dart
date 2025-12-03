import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendorapp/constants/AppColors.dart';
import 'package:vendorapp/cubits/editMovie/edit_movie_cubit.dart';
import 'package:vendorapp/cubits/editMovie/edit_movie_state.dart';
import 'package:vendorapp/models/Movie.dart';
import 'package:vendorapp/screens/editMovie/helpers/EditMovieHelper.dart';
import 'package:vendorapp/widgets/CustomTextField.dart';

class EditMovieForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;
  final Movie movie;
  final EditMovieState state;

  const EditMovieForm({
    Key? key,
    required this.formKey,
    required this.onSubmit,
    required this.movie,
    required this.state,
  }) : super(key: key);

  String _formatDateTime(DateTime dt) {
    final date = "${dt.day}/${dt.month}/${dt.year}";
    final time =
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    return "$date  •  $time";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----- IMAGE PICKER --------
              GestureDetector(
                onTap: () => EditMovieHelper.showImagePickerSheet(context),
                child: Center(
                  child: Container(
                    width: 180,
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primaryColor),
                      color: Colors.white,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: state.imageFile == null
                        ? Image.network(movie.image, fit: BoxFit.cover)
                        : Image.file(state.imageFile!, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "Movie Info",
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),

              // ----- TITLE INPUT -----
              CustomTextField(
                label: "Title",
                initialValue: state.title,
                onChanged: context.read<EditMovieCubit>().updateTitle,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Enter title" : null,
              ),
              const SizedBox(height: 14),

              // ----- DESCRIPTION INPUT -----
              CustomTextField(
                maxLines: 4,
                label: "Description",
                initialValue: state.description,
                onChanged: context.read<EditMovieCubit>().updateDescription,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Enter description" : null,
              ),
              const SizedBox(height: 14),

              // ----- PRICE INPUT -----
              CustomTextField(
                keyboardType: TextInputType.number,
                label: "Price (LE)",
                initialValue: state.price,
                onChanged: context.read<EditMovieCubit>().updatePrice,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Enter price" : null,
              ),
              const SizedBox(height: 20),

              // ---- SHOWTIME HEADER + ADD BTN ----
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Showtimes",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  TextButton.icon(
                    onPressed: () => EditMovieHelper.AddShowTime(context),
                    icon: const Icon(Icons.add, color: AppColors.primaryColor),
                    label: const Text(
                      "Add",
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              if (state.isLoadingTimes)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(),
                )
              else if (state.showTimes.isEmpty)
                const Text(
                  "No show times added yet.",
                  style: TextStyle(color: Colors.black45),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: state.showTimes.asMap().entries.map((entry) {
                    final index = entry.key;
                    final dt = entry.value;
                    return Chip(
                      label: Text(
                        _formatDateTime(dt),
                        style: const TextStyle(color: Colors.black87),
                      ),
                      backgroundColor: Colors.grey[300],
                      deleteIcon: const Icon(
                        Icons.close,
                        color: Colors.black87,
                      ),
                      onDeleted: () {
                        context.read<EditMovieCubit>().removeShowTimeAt(index);
                      },
                    );
                  }).toList(),
                ),

              const SizedBox(height: 22),

              // ----- UPDATE BUTTON -----
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isSubmitting ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state.isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          "Update",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
