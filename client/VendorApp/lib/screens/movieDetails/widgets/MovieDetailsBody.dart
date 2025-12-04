import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendorapp/cubits/movieDetails/MovieDetailsState.dart';
import 'package:vendorapp/cubits/movieDetails/movieDetailsCubit.dart';
import 'package:vendorapp/screens/movieDetails/widgets/MoviePoster.dart';
import 'package:vendorapp/screens/movieDetails/widgets/MoviePrice.dart';
import 'package:vendorapp/screens/movieDetails/widgets/MovieTitleAndDescription.dart';
import 'package:vendorapp/screens/movieDetails/widgets/SeatsSelector.dart';
import 'package:vendorapp/screens/movieDetails/widgets/ShowTimes.dart';

class MovieDetailsBody extends StatefulWidget {
  final MovieDetailsState state;

  const MovieDetailsBody({super.key, required this.state});

  @override
  State<MovieDetailsBody> createState() => _MovieDetailsBodyState();
}

class _MovieDetailsBodyState extends State<MovieDetailsBody> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.state.movie!;
    final timeShows = widget.state.timeShows;
    final selectedTimeShow = widget.state.selectedTimeShow;
    final selectedSeats = widget.state.selectedSeats;
    final reservedSeats = widget.state.reservedSeats;

    return SafeArea(
      child: SingleChildScrollView(
        controller: _scrollController, // 👈 keeps position
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
              selectable: true,
              onSelect: (ts) =>
                  context.read<MovieDetailsCubit>().changeShowTime(ts),
            ),
            const SizedBox(height: 24),

            SeatsSelector(
              selectable: false,
              selectedSeats: selectedSeats,
              reservedSeats: reservedSeats,
              onToggleSeat: (index) =>
                  context.read<MovieDetailsCubit>().toggleSeat(index),
            ),
            // const SizedBox(height: 24),

            // ConfirmBookingButton(
            //   enabled: selectedTimeShow != null && selectedSeats.isNotEmpty,
            //   onPressed: () {
            //     // TODO: handle confirm booking
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
