import 'package:customerapp/models/TicketItem.dart';
import 'package:customerapp/screens/myTickets/widgets/TicketWidgets.dart';
import 'package:customerapp/screens/ticketDetails/TicketDetails.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customerapp/constants/AppColors.dart';
import 'package:customerapp/cubits/ticketList/ticket_list_cubit.dart';
import 'package:customerapp/cubits/ticketList/ticket_list_state.dart';

class MyTicketsPage extends StatelessWidget {
  static const routeName = '/ticket-list';

  const MyTicketsPage({super.key});

  void _navigateToDetails(BuildContext context, TicketItem ticket) async {
    await Navigator.of(
      context,
    ).pushNamed(TicketDetailsPage.routeName, arguments: ticket);

    context.read<TicketListCubit>().fetchTickets();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketListCubit, TicketListState>(
      builder: (context, state) {
        if (state is TicketListLoading || state is TicketListInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TicketListError) {
          return Center(
            child: Text(
              'Error loading tickets: ${state.message}',
              style: const TextStyle(color: AppColors.secondaryTextColor),
            ),
          );
        }

        if (state is TicketListLoaded) {
          final tickets = state.tickets;

          if (tickets.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<TicketListCubit>().fetchTickets(),
              child: Center(
                child: ListView(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    const Center(
                      child: Text(
                        'You have no booked tickets yet.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<TicketListCubit>().fetchTickets(),
            child: ListView.builder(
              padding: EdgeInsets.only(top: 16),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return GestureDetector(
                  onTap: () => _navigateToDetails(context, ticket),
                  child: buildTicketCard(ticket),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
