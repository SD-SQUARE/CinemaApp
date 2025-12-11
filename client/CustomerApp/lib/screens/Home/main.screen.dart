import 'package:customerapp/screens/myTickets/myTickets.screen.dart';
import 'package:flutter/material.dart';
import 'package:customerapp/constants/AppColors.dart';
import 'package:customerapp/screens/movieList/MovieList.screen.dart';
import 'package:customerapp/screens/login/Login.screen.dart';
// <- If you have a login screen

class MainScreen extends StatefulWidget {
  static const routeName = '/main-screen';

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  final List<Widget> _pages = [MovieListPage(), MyTicketsPage()];

  final List<String> _titles = const ['Movie List', 'My tickets'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.jumpToPage(index);
  }

  Future<void> _logout() async {
    /// TODO: add Supabase logout or auth logic
    /// await Supabase.instance.client.auth.signOut();

    /// Example: navigate back to login
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,

      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(color: Colors.white),
        ),

        // ⭐ ADD LOGOUT ICON HERE ⭐
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),

      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: const Color(0xFF5C5C5C),
        selectedItemColor: AppColors.textColor,
        backgroundColor: AppColors.primaryColor,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Movie List'),
          BottomNavigationBarItem(
            icon: Icon(Icons.theater_comedy),
            label: 'My tickets',
          ),
        ],
      ),
    );
  }
}
