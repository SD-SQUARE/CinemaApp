import 'package:flutter/material.dart';
import 'package:customerapp/models/TimeShow.dart';
import 'package:customerapp/screens/movieDetails/widgets/ShowTimeCard.dart';

class ShowTimeCards extends StatelessWidget {
  final List<TimeShow> timeShows;
  final TimeShow? selected;
  final bool selectable;
  final ValueChanged<TimeShow?>? onSelect;

  const ShowTimeCards({
    super.key,
    required this.timeShows,
    required this.selected,
    this.selectable = true,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (timeShows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Show time",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: timeShows.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final ts = timeShows[index];

              final bool isSelected = selectable && selected == ts;

              return ShowTimeCard(
                timeShow: ts,
                isSelected: isSelected,
                selectable: selectable,
                onTap: !selectable || onSelect == null
                    ? null
                    : () => onSelect!(ts),
              );
            },
          ),
        ),
      ],
    );
  }
}
