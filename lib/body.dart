import 'package:flutter/material.dart';
import 'package:tastetrek/bookmark.dart';
import 'package:tastetrek/recipe.dart';
import 'package:tastetrek/recipepg.dart';
import 'package:tastetrek/explore.dart';

class body extends StatefulWidget {
  const body({super.key});

  @override
  State<body> createState() => _bodyState();
}

class _bodyState extends State<body> {
  List page = [HomePage(), Exp(), FavoritesPage()];

  int currentPageIndex = 0;
  void onTap(int index) {
    setState(() {
      currentPageIndex = index;
      print(currentPageIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Row(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     children: [
        //       Icon(Icons.restaurant_menu),
        //       SizedBox(width: 10),
        //       Text('Tastetrek'),
        //     ],
        //   ),
        // ),
        body: SafeArea(child: page[currentPageIndex]),
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTap,
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
          currentIndex: currentPageIndex,
        ));
  }
}
