import 'package:customerapp/cubits/ticketDetails/ticket_detail_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customerapp/models/TicketItem.dart';
import 'package:customerapp/services/supabase_client.dart';
import 'package:customerapp/constants/AppColors.dart';
import 'package:intl/intl.dart';
import 'package:customerapp/cubits/ticketDetails/ticket_details_state.dart';
import 'package:customerapp/screens/ticketDetails/widgets/buildCustomWidget.dart';

class TicketDetailsPage extends StatelessWidget {
  static const routeName = '/ticket-details';

  final TicketItem ticket;

  const TicketDetailsPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TicketDetailsCubit(ticket: ticket)..fetchCustomerName(),
      child: const _TicketDetailsView(),
    );
  }
}

class _TicketDetailsView extends StatelessWidget {
  const _TicketDetailsView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TicketDetailsCubit>();
    final ticket = cubit.ticket;

    final String date = DateFormat('EEE, MMM d, yyyy').format(ticket.showTime);
    final String time = DateFormat('h:mm a').format(ticket.showTime);
    final String cost = 'E£ ${ticket.cost.toStringAsFixed(2)}';
    final String imageUrl =
        "${SupabaseService.getURL()}${ticket.movieImageUrl}";

    final double totalPadding = 16.0 * 4;
    final double halfItemWidth =
        (MediaQuery.of(context).size.width - totalPadding) / 2;
    void _handleCancel(BuildContext context, TicketDetailsCubit cubit) async {
      final errorMessage = await cubit.cancelBooking();

      if (cubit.state.isCancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking successfully cancelled.')),
        );

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
      } else if (errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cancellation failed: $errorMessage')),
        );
      }
    }

    return BlocBuilder<TicketDetailsCubit, TicketDetailsState>(
      builder: (context, state) {
        final name = state.customerName;

        return Scaffold(
          backgroundColor: AppColors.secondaryColor,
          appBar: AppBar(
            title: const Text(
              'Ticket Details',
              style: TextStyle(color: AppColors.textColor),
            ),
            iconTheme: const IconThemeData(color: AppColors.textColor),
            backgroundColor: AppColors.primaryColor,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    imageUrl,
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.movie,
                      size: 150,
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  ticket.movieTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 24.0),

                Card(
                  color: AppColors.cardColor,
                  elevation: 6.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'TICKET ID: #${ticket.id}',
                            style: TextStyle(
                              color: AppColors.secondaryTextColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Divider(
                          color: AppColors.secondaryTextColor.withOpacity(0.3),
                          height: 30,
                        ),

                        buildCustomDetail('Customer Name', name),
                        const SizedBox(height: 16.0),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            buildCustomDetail('Date', date),

                            buildCustomDetail('Time', time),
                          ],
                        ),

                        const SizedBox(height: 16.0),

                        buildCustomDetail('Seats', ticket.seats),

                        const SizedBox(height: 16.0),

                        buildCustomDetail('Total Price', cost),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),

                if (!state.isCancelled)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: state.isCancelling
                          ? null
                          : () => _handleCancel(context, cubit),
                      icon: state.isCancelling
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.cancel,
                              color: AppColors.textColor,
                            ),
                      label: Text(
                        state.isCancelling ? 'Cancelling...' : 'Cancel Booking',
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.textColor,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        disabledBackgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                else
                  Text(
                    'This booking has been cancelled.',
                    style: TextStyle(color: Colors.red[400], fontSize: 18),
                  ),
                const SizedBox(height: 30.0),
              ],
            ),
          ),
        );
      },
    );
  }
}
