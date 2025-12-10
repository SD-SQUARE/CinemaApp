class TicketItem {
  final String id;
  final String movieTitle;
  final String movieImageUrl;
  final String seats;
  final double cost;
  final DateTime showTime;

  TicketItem({
    required this.id,
    required this.movieTitle,
    required this.movieImageUrl,
    required this.seats,
    required this.cost,
    required this.showTime,
  });
}