import 'package:flutter/foundation.dart';
import 'package:vendorapp/models/TicketSummery.dart';

@immutable
abstract class StatisticsState {}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final TicketSummary summary;

  StatisticsLoaded({required this.summary});
}

class StatisticsError extends StatisticsState {
  final String message;

  StatisticsError({required this.message});
}