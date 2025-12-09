import 'package:customerapp/models/TicketItem.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:customerapp/constants/AppColors.dart';
import 'package:customerapp/services/supabase_client.dart';

Widget buildDetailRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(top: 4.0),
    child: Row(
      children: [
        Icon(icon, size: 16, color: AppColors.accentColor),
        const SizedBox(width: 8.0),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryTextColor,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: AppColors.textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

Widget buildTicketCard(TicketItem ticket) {
  final dateFormat = DateFormat('EEE, MMM d, yyyy');
  final timeFormat = DateFormat('h:mm a');
  final date = dateFormat.format(ticket.showTime);
  final time = timeFormat.format(ticket.showTime);

  final String imageUrl = "${SupabaseService.getURL()}${ticket.movieImageUrl}";

  return Card(
    color: AppColors.cardColor,
    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    elevation: 4.0,
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              imageUrl,
              width: 100,
              height: 155,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.movie,
                size: 80,
                color: AppColors.secondaryTextColor,
              ),
            ),
          ),
          const SizedBox(width: 16.0),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ticket.movieTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8.0),

                buildDetailRow(Icons.calendar_today, 'Date', date),
                buildDetailRow(Icons.access_time, 'Time', time),
                buildDetailRow(Icons.event_seat, 'Seats', ticket.seats),
                buildDetailRow(
                  Icons.currency_pound,
                  'Cost',
                  'E£ ${ticket.cost.toStringAsFixed(2)}',
                ),
                buildDetailRow(
                  Icons.confirmation_number,
                  'Ticket ID',
                  '#${ticket.id}',
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
