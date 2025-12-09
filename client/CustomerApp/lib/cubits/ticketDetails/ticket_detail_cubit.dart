import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customerapp/services/supabase_client.dart';
import 'package:customerapp/models/TicketItem.dart';
import 'package:customerapp/cubits/ticketDetails/ticket_details_state.dart';

class TicketDetailsCubit extends Cubit<TicketDetailsState> {
  final TicketItem ticket;

  TicketDetailsCubit({required this.ticket})
    : super(TicketDetailsState.initial());

  Future<void> fetchCustomerName() async {
    try {
      final String? userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        emit(state.copyWith(customerName: 'Error: Not logged in'));
        return;
      }

      final response = await SupabaseService.client
          .from('customers')
          .select('name')
          .eq('uid', userId)
          .single();

      final String name = response['name'] ?? 'Guest';
      emit(state.copyWith(customerName: name));
    } catch (e) {
      emit(
        state.copyWith(
          customerName: 'Error fetching name',
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<String?> cancelBooking() async {
    emit(state.copyWith(isCancelling: true, errorMessage: null));

    try {
      final response = await SupabaseService.client.rpc(
        'cancel_ticket',
        params: {'p_ticket_id': ticket.id},
      );

      if (response is Map && response['ok'] == true) {
        emit(state.copyWith(isCancelled: true, isCancelling: false));
        return null;
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
      final String errorMessage = e.toString().split(': ').last;
      emit(state.copyWith(isCancelling: false, errorMessage: errorMessage));
      return errorMessage;
    }
  }
}
