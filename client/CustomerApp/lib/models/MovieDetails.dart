class MovieDetails {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  final List<DateTime> showTimes;

  MovieDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.showTimes,
  });

  factory MovieDetails.fromMap(Map<String, dynamic> map) {
    return MovieDetails(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      imageUrl: map['image'] as String,
      price: (map['price'] as num).toDouble(),
      showTimes: ((map['show_times'] ?? []) as List)
          .map<DateTime>((e) => DateTime.parse(e as String))
          .toList(),
    );
  }
}
