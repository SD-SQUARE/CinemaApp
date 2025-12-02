import 'package:flutter/material.dart';
import 'package:vendorapp/constants/AppColors.dart';
import 'package:vendorapp/models/Movie.dart';
import 'package:vendorapp/screens/movieDetails/MovieDetailsPage.dart';
import 'package:vendorapp/utils/TextHelper.dart';

class MovieItem extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  MovieItem({required this.movie, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  movie.image,
                  fit: BoxFit.cover, // THIS CROPS THE IMAGE
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.black.withOpacity(0.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TextHelper.getTruncatedText(movie.title, 18),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        TextHelper.getTruncatedText(movie.description, 75),
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        "${movie.price} LE",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MovieDetailsPage(movieId: movie.id),
          ),
        );
      },
    );
  }
}
