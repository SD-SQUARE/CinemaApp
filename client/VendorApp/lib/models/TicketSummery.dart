class TicketDetail {
  final String ticketId;
  final String customerName;
  final String movieName;
  final DateTime showTime;
  final double totalPrice;

  TicketDetail({
    required this.ticketId,
    required this.customerName,
    required this.movieName,
    required this.showTime,
    required this.totalPrice,
  });

  factory TicketDetail.fromJson(Map<String, dynamic> json) {
    return TicketDetail(
      ticketId: json['ticket_id'] as String,
      customerName: json['customer_name'] as String,
      movieName: json['movie_name'] as String,
      showTime: DateTime.parse(json['show_time'] as String),
      totalPrice: (json['total_price'] as num).toDouble(),
    );
  }
}

class TicketSummary {
  final int totalTickets;
  final double totalPrice;
  final List<TicketDetail> tickets;

  TicketSummary({
    required this.totalTickets,
    required this.totalPrice,
    required this.tickets,
  });

  factory TicketSummary.fromJson(Map<String, dynamic> json) {
    final List<dynamic> ticketListJson = json['tickets'] ?? [];

    return TicketSummary(
      totalTickets: json['total_tickets'] as int,
      totalPrice: (json['total_price'] as num).toDouble(),
      tickets: ticketListJson.map((t) => TicketDetail.fromJson(t)).toList(),
    );
  }
}
