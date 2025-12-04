class Movie {
  final String id;
  final String title;
  final String description;
  final double price;
  final int seatsNumber;
  final String image;

  Movie({
    required this.title,
    required this.description,
    required this.price,
    required this.seatsNumber,
    required this.image,
    required this.id,
  });

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num).toDouble(),
      seatsNumber: map['seats_number'] ?? 0,
      image: map['image'] ?? '',
      id: map['id'],
    );
  }
}
