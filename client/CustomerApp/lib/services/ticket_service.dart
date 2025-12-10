import 'package:customerapp/models/TicketItem.dart';
import 'package:customerapp/services/supabase_client.dart';
import 'package:flutter/foundation.dart';

Future<String?> getCustomerId() async {
  try {
    final String? userId = SupabaseService.client.auth.currentUser?.id;

    if (userId == null) return null;

    final response = await SupabaseService.client
        .from('customers')
        .select('id')
        .eq('uid', userId)
        .single();

    return response['id'] as String?;
  } catch (e) {
    debugPrint('Exception fetching customer id: $e');
    return null;
  }
}

Future<List<TicketItem>> fetchTicketsData() async {
  final String? customerId = await getCustomerId();
  if (customerId == null) {
    debugPrint('No customer ID found. Cannot fetch tickets.');
    return [];
  }

  try {
    final List<dynamic> response = await SupabaseService.client
        .from('tickets')
        .select('id, total_price, seats, timeshows(time, movies(title, image))')
        .eq('cid', customerId);

    return response.map((ticketData) {
      final timeshow = ticketData['timeshows'];
      final movie = timeshow['movies'];

      final List<dynamic> rawSeats = ticketData['seats'] as List<dynamic>;
      final String formattedSeats = rawSeats.join(', ');

      final String imagePathFragment = movie['image'] as String;

      return TicketItem(
        id: ticketData['id'] as String,
        cost: (ticketData['total_price'] as num).toDouble(),
        seats: formattedSeats,
        showTime: DateTime.parse(timeshow['time'] as String),
        movieTitle: movie['title'] as String,
        movieImageUrl: imagePathFragment,
      );
    }).toList();
  } catch (e) {
    debugPrint('Exception fetching tickets: $e');
    return [];
  }
}
