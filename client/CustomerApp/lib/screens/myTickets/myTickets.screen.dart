import 'package:customerapp/models/TicketItem.dart';
import 'package:customerapp/utils/TicketWidgets.dart';
import 'package:flutter/material.dart';
import 'package:customerapp/constants/AppColors.dart';
import 'package:customerapp/services/ticket_service.dart';

class MyTicketsPage extends StatelessWidget {
  static const routeName = '/ticket-list';

  const MyTicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TicketItem>>(
      future: fetchTicketsData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading tickets: ${snapshot.error}',
              style: const TextStyle(color: AppColors.secondaryTextColor),
            ),
          );
        }

        List<TicketItem> tickets = snapshot.data ?? [];

        if (tickets.isNotEmpty) {
          tickets = tickets.reversed.toList();
        }

        if (tickets.isEmpty) {
          return const Center(
            child: Text(
              'You have no booked tickets yet.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.secondaryTextColor,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            return buildTicketCard(tickets[index]);
          },
        );
      },
    );
  }
}
