import 'package:customerapp/models/TicketItem.dart';
import 'package:customerapp/screens/myTickets/widgets/TicketWidgets.dart';
import 'package:customerapp/ticketDetails/TicketDetails.screen.dart';
import 'package:flutter/material.dart';
import 'package:customerapp/constants/AppColors.dart';
import 'package:customerapp/services/ticket_service.dart';

class MyTicketsPage extends StatefulWidget {
  static const routeName = '/ticket-list';

  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  late Future<List<TicketItem>> _ticketsFuture;

  @override
  void initState() {
    super.initState();

    _ticketsFuture = fetchTicketsData();
  }

  void _refreshTickets() {
    setState(() {
      _ticketsFuture = fetchTicketsData();
    });
  }

  void _navigateToDetails(TicketItem ticket) async {
    await Navigator.of(
      context,
    ).pushNamed(TicketDetailsPage.routeName, arguments: ticket);

    _refreshTickets();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TicketItem>>(
      future: _ticketsFuture,
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

        return RefreshIndicator(
          onRefresh: () async {
            _refreshTickets();
            await _ticketsFuture;
          },
          child: ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return GestureDetector(
                onTap: () => _navigateToDetails(ticket),
                child: buildTicketCard(ticket),
              );
            },
          ),
        );
      },
    );
  }
}
