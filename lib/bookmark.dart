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
  List<dynamic> _favoriteRecipes = [];

  @override
  void initState() {
    super.initState();
    _favoriteRecipes = Store.getBook() ?? [];

    List<dynamic> recipeList = jsonDecode(_favoriteRecipes.toString());
    List<Recipe> recipeMap = Recipe.recipeFromSnapshot(recipeList);
    print("recipe = $recipeMap");
  }

  @override
  Widget build(BuildContext context) {
    var recipes;
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Recipes'),
      ),
    );
  }

  void navigateToRecipePage(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipePage(recipe: recipe),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final void Function() onTap;

  RecipeCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(recipe.name),
      subtitle: Text(getCalorieInformation()),
      leading: Image.network(recipe.image),
      onTap: onTap,
    );
  }

  String getCalorieInformation() {
    if (recipe.cal != null) {
      return recipe.cal;
    }
    return "Calorie information not available";
  }
}
