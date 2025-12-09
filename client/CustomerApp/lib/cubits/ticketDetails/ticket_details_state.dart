import 'package:flutter/material.dart';

@immutable
class TicketDetailsState {
  final String customerName;
  final bool isCancelled;
  final bool isCancelling;
  final String? errorMessage;

  const TicketDetailsState({
    required this.customerName,
    this.isCancelled = false,
    this.isCancelling = false,
    this.errorMessage,
  });

  factory TicketDetailsState.initial() =>
      const TicketDetailsState(customerName: 'Loading...');

  TicketDetailsState copyWith({
    String? customerName,
    bool? isCancelled,
    bool? isCancelling,
    String? errorMessage,
  }) {
    return TicketDetailsState(
      customerName: customerName ?? this.customerName,
      isCancelled: isCancelled ?? this.isCancelled,
      isCancelling: isCancelling ?? this.isCancelling,
      errorMessage: errorMessage,
    );
  }
}
