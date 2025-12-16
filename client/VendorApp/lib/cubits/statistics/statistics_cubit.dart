import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendorapp/services/stat_service.dart';
import 'package:vendorapp/cubits/statistics/statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit() : super(StatisticsInitial()) {
  }

  Future<void> fetchSummary() async {
    if (state is StatisticsLoading) return;

    emit(StatisticsLoading());
    try {
      final summary = await fetchTicketSummary();

      if (summary.totalTickets == 0) {
        emit(StatisticsLoaded(summary: summary));
      } else {
        emit(StatisticsLoaded(summary: summary));
      }
    } catch (e) {
      emit(StatisticsError(message: e.toString()));
    }
  }
}
