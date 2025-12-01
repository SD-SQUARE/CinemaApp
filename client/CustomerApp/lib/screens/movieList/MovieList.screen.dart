import 'package:customerapp/services/supabase_client.dart';
import 'package:flutter/material.dart';
import 'package:customerapp/screens/login/Login.screen.dart';

class MovieListScreen extends StatelessWidget {
  static const routeName = '/movie-list';

  MovieListScreen({super.key});

  Future<String> getUserName() async {
    try {
      final response = await SupabaseService.client
          .from('customers')
          .select('name')
          .eq('uid', SupabaseService.client.auth.currentUser!.id)
          .single();

      if (response.isEmpty) {
        print('Error fetching user: ${response}');
        return "";
      }

      return response['name'] ?? "";
    } catch (e) {
      print('Exception fetching user: $e');
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movie List')),
      body: Center(
        child: FutureBuilder<String>(
          future: getUserName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            final name = snapshot.data ?? "";
            return InkWell(
              onTap: () async {
                await SupabaseService.client.auth.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil( 
                  LoginScreen.routeName,
                  (route)=>false
                  );
              },
              child: Text('Welcome $name! This is the Movie List Screen'),
            );
          },
        ),
      ),
    );
  }
}
