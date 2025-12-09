import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customerapp/services/ticket_service.dart';
import 'package:customerapp/models/TicketItem.dart';
import 'package:customerapp/cubits/ticketList/ticket_list_state.dart';

class TicketListCubit extends Cubit<TicketListState> {
  TicketListCubit() : super(TicketListInitial()) {
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    if (state is TicketListLoading) return;

    emit(TicketListLoading());

    try {
      List<TicketItem> tickets = await fetchTicketsData();

      if (tickets.isNotEmpty) {
        tickets = tickets.reversed.toList();
      }

      emit(TicketListLoaded(tickets: tickets));
    } catch (e) {
      emit(TicketListError(message: e.toString()));
    }
  }
}
