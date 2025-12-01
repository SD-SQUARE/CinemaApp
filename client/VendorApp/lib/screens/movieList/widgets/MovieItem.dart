import 'package:flutter/material.dart';
import 'package:vendorapp/models/Movie.dart';
import 'package:vendorapp/utils/TextHelper.dart';

class MovieItem extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  MovieItem({required this.movie, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Movie Image
          Positioned.fill(child: Image.network(movie.image, fit: BoxFit.cover)),

          // ▸ Three dots menu (Edit / Delete)
          Positioned(
            top: 6,
            right: 6,
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == "edit" && onEdit != null) onEdit!();
                if (value == "delete" && onDelete != null) onDelete!();
              },
              color: Colors.white,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "edit",
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue),
                      SizedBox(width: 8),
                      Text("Edit"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "delete",
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Delete"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Overlay Text
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.black.withOpacity(0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TextHelper.getTruncatedText(movie.title, 18),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    TextHelper.getTruncatedText(movie.description, 75),
                    style: TextStyle(color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${movie.price} LE",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
