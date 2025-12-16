import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vendorapp/services/notification_service.dart';
import 'package:vendorapp/services/supabase_client.dart';

class TicketNotificationsCubit extends Cubit<int> {
  TicketNotificationsCubit() : super(0) {
    _subscribeToAllTickets();
  }

  RealtimeChannel? _ticketChannel;

  @override
  Future<void> close() {
    _ticketChannel?.unsubscribe();
    return super.close();
  }

  void _subscribeToAllTickets() {
    print('Setting up global ticket notifications subscription');

    final client = SupabaseService.client;

    _ticketChannel = client.channel('all_tickets_notifications')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'tickets',
        callback: (payload) async {
          try {
            print('New ticket booked: ${payload.newRecord}');

            final ticketSeats = payload.newRecord['seats'] as List;
            final movieId = payload.newRecord['mid'] as String;
            final timeShowId = payload.newRecord['tid'] as String;

            // Fetch movie details
            final movieRes = await client
                .from('movies')
                .select('title')
                .eq('id', movieId)
                .maybeSingle();

            final movieName = movieRes?['title'] ?? 'Unknown Movie';

            // Fetch showtime details
            final showtimeRes = await client
                .from('timeshows')
                .select('time')
                .eq('id', timeShowId)
                .maybeSingle();

            final showtime = showtimeRes?['time'];
            final formattedShowtime = showtime != null
                ? DateTime.parse(showtime).toLocal().toString().split('.')[0]
                : 'Unknown Time';

            final seatList = ticketSeats.join(", ");

            // Show notification
            // NotificationService.showNotification(
            //   title: "New Ticket Booked! 🎬",
            //   body:
            //       "Seats $seatList booked for '$movieName' at $formattedShowtime",
            //   id: Random().nextInt(9999),
            // );

            emit(state + 1);
          } catch (e) {
            print('Error processing ticket notification: $e');
          }
        },
      )
      ..subscribe((status, error) {
        if (error != null) {
          print('Global ticket subscription error: $error');
        }
      });
  }
}
