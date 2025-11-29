

import 'package:flutter/material.dart';

class MovieListScreen extends StatelessWidget {

static final routeName = '/movie-list'; 
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie List'),
      ),
      body: Center(
        child: Text('This is the Movie List Screen'),
      ),
    );
  }
}