import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tastetrek/recipe.dart';
import 'dart:convert';
import 'package:tastetrek/recipepg.dart';
import 'package:tastetrek/share.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<String> _favoriteRecipes = [];

  @override
  void initState() {
    super.initState();
    _favoriteRecipes = Store.getBook() ?? [];
    print(_favoriteRecipes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Recipes'),
      ),
      body: ListView.builder(
        itemCount: _favoriteRecipes.length,
        itemBuilder: (context, index) {
          return ListTile(

              // Add more information or customize the list item as needed
              );
        },
      ),
    );
  }
}
