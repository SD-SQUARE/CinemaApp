import 'package:customerapp/ticketDetails/widgets/buildCustomWidget.dart';
import 'package:flutter/material.dart';
import 'package:customerapp/models/TicketItem.dart';
import 'package:customerapp/services/supabase_client.dart';
import 'package:customerapp/constants/AppColors.dart';
import 'package:intl/intl.dart';

class TicketDetailsPage extends StatefulWidget {
  static const routeName = '/ticket-details';
  final TicketItem ticket;

  const TicketDetailsPage({super.key, required this.ticket});

  @override
  State<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  String _customerName = 'Loading...';
  bool _isCancelled = false;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _fetchCustomerName();
  }

  Future<void> _fetchCustomerName() async {
    try {
      final String? userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) setState(() => _customerName = 'Error: Not logged in');
        return;
      }

      final response = await SupabaseService.client
          .from('customers')
          .select('name')
          .eq('uid', userId)
          .single();

      if (mounted) {
        setState(() {
          _customerName = response['name'] ?? 'Guest';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _customerName = 'Error fetching name';
        });
      }
      debugPrint('Exception fetching customer name: $e');
    }
  }

  Future<void> _cancelBooking() async {
    setState(() {
      _isCancelling = true;
    });

    try {
      final response = await SupabaseService.client.rpc(
        'cancel_ticket',
        params: {'p_ticket_id': widget.ticket.id},
      );

      if (response is Map && response['ok'] == true) {
        if (mounted) {
          setState(() {
            _isCancelled = true;
            _isCancelling = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking successfully cancelled.')),
          );

          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pop();
          });
        }
      } else {
        String reason = 'Unknown error';
        if (response is Map && response.containsKey('reason')) {
          reason = response['reason'];

          switch (reason) {
            case 'ticket_not_found':
              reason = 'Ticket not found or already cancelled.';
              break;
            case 'not_owner':
              reason = 'You do not have permission to cancel this ticket.';
              break;
            case 'expired':
              reason =
                  'The showtime has already passed. Cancellation is not possible.';
              break;
          }
        }

        throw Exception(reason);
      }
    } catch (e) {
      debugPrint('Cancellation failed: $e');
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cancellation failed: ${e.toString().split(': ').last}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;
    final String date = DateFormat('EEE, MMM d, yyyy').format(ticket.showTime);
    final String time = DateFormat('h:mm a').format(ticket.showTime);
    final String cost = 'E£ ${ticket.cost.toStringAsFixed(2)}';
    final String imageUrl =
        "${SupabaseService.getURL()}${ticket.movieImageUrl}";

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
                    Text(
                      'TICKET ID: #${ticket.id}',
                      style: TextStyle(
                        color: AppColors.secondaryTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(
                      color: AppColors.secondaryTextColor.withOpacity(0.3),
                      height: 30,
                    ),

                    buildCustomDetail('Customer Name', _customerName),
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

            if (!_isCancelled)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isCancelling ? null : _cancelBooking,
                  icon: _isCancelling
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.cancel, color: AppColors.textColor),
                  label: Text(
                    _isCancelling ? 'Cancelling...' : 'Cancel Booking',
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
  }
}
