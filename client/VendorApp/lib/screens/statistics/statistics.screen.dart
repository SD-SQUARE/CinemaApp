import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendorapp/constants/AppColors.dart';
import 'package:vendorapp/models/TicketSummery.dart';
import 'package:vendorapp/screens/statistics/widgets/summaryCardWidget.dart';
import 'package:vendorapp/screens/statistics/widgets/ticketStatWidget.dart';
import 'package:intl/intl.dart';
import 'package:vendorapp/cubits/statistics/statistics_cubit.dart';
import 'package:vendorapp/cubits/statistics/statistics_state.dart';

class StatisticsPage extends StatelessWidget {
  static const routeName = '/statistics';

  const StatisticsPage({super.key});

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

      body: BlocBuilder<StatisticsCubit, StatisticsState>(
        builder: (context, state) {
          if (state is StatisticsLoading || state is StatisticsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StatisticsError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: TextStyle(color: AppColors.secondaryTextColor),
              ),
            );
          }

          if (state is StatisticsLoaded) {
            final summary = state.summary;

            final currencyFormatter = NumberFormat.currency(
              locale: 'en_US',
              symbol: '',
              decimalDigits: 2,
            );

            final formattedRevenue = currencyFormatter.format(
              summary.totalPrice,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 14.0,
                  ),
                  child: Row(
                    children: [
                      SummaryCardWidget(
                        title: 'Total Tickets Sold',
                        value: summary.totalTickets.toString(),
                        icon: Icons.local_activity,
                        color: AppColors.accentColor,
                      ),
                      SummaryCardWidget(
                        title: 'Total Revenue',
                        value: formattedRevenue,
                        icon: Icons.currency_pound,
                        color: AppColors.accentColor,
                      ),
                    ],
                  ),
                ),

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

                Expanded(
                  child: summary.tickets.isEmpty
                      ? Center(
                          child: Text(
                            'No sales data available.',
                            style: TextStyle(
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: summary.tickets.length,
                          itemBuilder: (context, index) {
                            return TicketStatItem(
                              ticket: summary.tickets[index],
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
