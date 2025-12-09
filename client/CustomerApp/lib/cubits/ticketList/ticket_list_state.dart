import 'package:flutter/material.dart';
import 'package:customerapp/models/TicketItem.dart';

@immutable
abstract class TicketListState {}

class TicketListInitial extends TicketListState {}

class TicketListLoading extends TicketListState {}

class TicketListLoaded extends TicketListState {
  final List<TicketItem> tickets;

  TicketListLoaded({required this.tickets});
}

class TicketListError extends TicketListState {
  final String message;

  TicketListError({required this.message});
}
