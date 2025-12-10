// This widget contains the Bottom Navigation Bar and manages navigation
import 'package:flutter/material.dart';
import 'package:vendorapp/constants/AppColors.dart';
import 'package:vendorapp/screens/movieList/MovieList.screen.dart';
import 'package:vendorapp/screens/statistics/statistics.screen.dart';

class NavigationBarSection extends StatefulWidget {
  const NavigationBarSection({super.key});

  @override
  _NavigationBarStateSection createState() => _NavigationBarStateSection();
}

class _NavigationBarStateSection extends State<NavigationBarSection> {
  int _selectedIndex = 0;

  // List of screens to navigate to
  final List<Widget> _pages = [MovieListPage(), StatisticsPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _pages[_selectedIndex]),
        BottomNavigationBar(
          unselectedItemColor: const Color(0xFF5C5C5C),
          selectedItemColor: AppColors.textColor,
          backgroundColor: AppColors.primaryColor,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped, // Handle tab change
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.movie),
              label: 'Movie List',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Statistics',
            ),
          ],
        ),
      ],
    );
  }
}
