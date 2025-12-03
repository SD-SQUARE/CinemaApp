import 'package:flutter/material.dart';
import 'package:vendorapp/models/Movie.dart';
import 'package:vendorapp/screens/movieDetails/MovieDetailsPage.dart';
import 'MovieCard.dart';
import 'MovieSwipeBackgrounds.dart';
import 'MovieDeleteDialog.dart';

class MovieItem extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool swipeable;

  const MovieItem({
    super.key,
    required this.movie,
    this.onEdit,
    this.onDelete,
    this.swipeable = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = MovieCard(
      movie: movie,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MovieDetailsPage(movieId: movie.id),
          ),
        );
      },
    );

    if (!swipeable) return content;

    return Dismissible(
      key: ValueKey(movie.id),

      background: MovieSwipeBackgrounds.editBackground(),
      secondaryBackground: MovieSwipeBackgrounds.deleteBackground(),

      confirmDismiss: (direction) async {
        // EDIT
        if (direction == DismissDirection.startToEnd) {
          if (onEdit != null) onEdit!();
          return false; // don't dismiss UI
        }

        // DELETE
        if (direction == DismissDirection.endToStart) {
          if (onDelete == null) return false;

          final confirmed = await MovieDeleteDialog.show(context, movie.title);
          if (confirmed) {
            onDelete!();
            return true;
          }
          return false;
        }

        return false;
      },

      child: content,
    );
  }
}
