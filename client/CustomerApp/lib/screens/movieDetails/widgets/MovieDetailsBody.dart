import 'package:customerapp/screens/movieDetails/widgets/ConfirmBookingButton.dart';
import 'package:customerapp/screens/movieDetails/widgets/TicketSummary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customerapp/cubits/movieDetails/MovieDetailsState.dart';
import 'package:customerapp/cubits/movieDetails/movieDetailsCubit.dart';
import 'package:customerapp/screens/movieDetails/widgets/MoviePoster.dart';
import 'package:customerapp/screens/movieDetails/widgets/MoviePrice.dart';
import 'package:customerapp/screens/movieDetails/widgets/MovieTitleAndDescription.dart';
import 'package:customerapp/screens/movieDetails/widgets/SeatsSelector.dart';
import 'package:customerapp/screens/movieDetails/widgets/ShowTimes.dart';

class MovieDetailsBody extends StatelessWidget {
  final MovieDetailsState state;

  const MovieDetailsBody({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final movie = state.movie!;
    final timeShows = state.timeShows;
    final selectedTimeShow = state.selectedTimeShow;
    final selectedSeats = state.selectedSeats;
    final reservedSeats = state.reservedSeats;
    final seatCount = selectedSeats.length;
    final totalPrice = seatCount * movie.price;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MoviePoster(imageUrl: movie.imageUrl),
            const SizedBox(height: 16),

            MovieTitleAndDescription(
              title: movie.title,
              description: movie.description,
            ),
            const SizedBox(height: 16),

            MoviePrice(price: movie.price),
            const SizedBox(height: 20),

            ShowTimeCards(
              timeShows: timeShows,
              selected: selectedTimeShow,
              onSelect: (ts) =>
                  context.read<MovieDetailsCubit>().changeShowTime(ts),
            ),
            const SizedBox(height: 24),

            SeatsSelector(
              selectedSeats: selectedSeats,
              reservedSeats: reservedSeats,
              onToggleSeat: (index) =>
                  context.read<MovieDetailsCubit>().toggleSeat(index),
            ),

            SizedBox(height: 15),

            const SizedBox(height: 24),

            if (selectedSeats.isNotEmpty) ...[
              TicketSummary(
                seatCount: seatCount,
                pricePerSeat: movie.price,
                totalPrice: totalPrice,
                selectedSeats: selectedSeats,
              ),
              const SizedBox(height: 24),
            ],

            ConfirmBookingButton(
              enabled: selectedTimeShow != null && selectedSeats.isNotEmpty,
              onPressed: () async {
                final cubit = context.read<MovieDetailsCubit>();
                await cubit.bookSelectedSeats();

                final state = cubit.state;

                if (state.bookingSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking successful!')),
                  );
                  // optional: navigate to "My Tickets" page
                } else if (state.bookingErrorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.bookingErrorMessage!)),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
