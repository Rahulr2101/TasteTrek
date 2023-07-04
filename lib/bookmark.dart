import 'package:flutter/material.dart';

class Exp extends StatelessWidget {
  const Exp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class Fav extends StatelessWidget {
  final int currentPageIndex;

  const Fav({required this.currentPageIndex, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Text('bookmark'),
      ),
    );
  }
}
