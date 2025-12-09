// lib/screens/statistics_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vendorapp/constants/AppColors.dart';
import 'package:vendorapp/models/TicketSummery.dart';
import 'package:vendorapp/services/stat_service.dart';

class StatisticsPage extends StatelessWidget {
  static const routeName = '/statistics';

  const StatisticsPage({super.key});

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        color: AppColors.cardColor,
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: AppColors.accentColor, width: 5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 30, color: color),
                    const SizedBox(width: 10),
                    Text(
                      value,
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketListItem(TicketDetail ticket) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      color: AppColors.cardColor,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      child: ListTile(
        title: Text(
          ticket.movieName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer: ${ticket.customerName}',
              style: TextStyle(color: AppColors.secondaryTextColor),
            ),
            Text(
              'Showtime: ${dateFormat.format(ticket.showTime)} at ${timeFormat.format(ticket.showTime)}',
              style: TextStyle(color: AppColors.secondaryTextColor),
            ),
          ],
        ),
        trailing: Text(
          'E£ ${ticket.totalPrice.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.accentColor,
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        title: Text(
          'Sales Statistics',
          style: TextStyle(color: AppColors.textColor),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: FutureBuilder<TicketSummary>(
        future: fetchTicketSummary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: AppColors.secondaryTextColor),
              ),
            );
          }

          final summary = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Summary Cards ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 14.0,
                ),
                child: Row(
                  children: [
                    _buildSummaryCard(
                      title: 'Total Tickets Sold',
                      value: summary.totalTickets.toString(),
                      icon: Icons.local_activity,
                      color: AppColors.accentColor,
                    ),
                    _buildSummaryCard(
                      title: 'Total Revenue',
                      value: summary.totalPrice.toStringAsFixed(2),
                      icon: Icons.currency_pound,
                      color: AppColors.accentColor,
                    ),
                  ],
                ),
              ),

              // --- Tickets List Header ---
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  top: 10.0,
                  bottom: 8.0,
                ),
                child: Text(
                  'Recent Sales (${summary.tickets.length} tickets)',
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // --- Tickets List ---
              Expanded(
                child: summary.tickets.isEmpty
                    ? Center(
                        child: Text(
                          'No sales data available.',
                          style: TextStyle(color: AppColors.secondaryTextColor),
                        ),
                      )
                    : ListView.builder(
                        itemCount: summary.tickets.length,
                        itemBuilder: (context, index) {
                          return _buildTicketListItem(summary.tickets[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
