import 'package:flutter/material.dart';
import 'package:tastetrek/bookmark.dart';
import 'package:tastetrek/recipe.dart';
import 'package:tastetrek/recipepg.dart';

class body extends StatefulWidget {
  const body({super.key});

  @override
  State<body> createState() => _bodyState();
}

class _bodyState extends State<body> {
  List page = [HomePage(), Fav()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: page[0],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline),
              label: 'Bookmark',
            ),
          ],
        ));
  }
}
