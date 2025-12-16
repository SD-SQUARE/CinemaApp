// This widget contains the Bottom Navigation Bar and manages navigation
import 'package:flutter/material.dart';
import 'package:vendorapp/constants/AppColors.dart';
import 'package:vendorapp/screens/movieList/MovieList.screen.dart';
import 'package:vendorapp/screens/statistics/statistics.screen.dart';


class NavigationBarSection extends StatefulWidget {
  const NavigationBarSection({super.key});

  @override
  State<NavigationBarSection> createState() => _NavigationBarStateSection();
}

class _NavigationBarStateSection extends State<NavigationBarSection> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return  MovieListPage();
      case 1:
        return  StatisticsPage();
      default:
        return  MovieListPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPage(),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: const Color(0xFF5C5C5C),
        selectedItemColor: AppColors.textColor,
        backgroundColor: AppColors.primaryColor,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
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
    );
  }
}
