import 'package:vendorapp/models/TicketSummery.dart';
import 'package:vendorapp/services/supabase_client.dart';

Future<TicketSummary> fetchTicketSummary() async {
  try {
    final response = await SupabaseService.client.rpc(
      'get_tickets_summary',
      params: {},
    );

    return TicketSummary.fromJson(response);
  } catch (e) {
    print('Error fetching ticket summary: $e');

    return TicketSummary(totalTickets: 0, totalPrice: 0.0, tickets: []);
  }
}
