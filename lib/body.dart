import 'package:flutter/material.dart';
import 'package:tastetrek/home.dart';
import 'package:tastetrek/recipe.api.dart';
import 'package:tastetrek/recipe.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controllersearch = TextEditingController();
  late List<Recipe> _recipes;
  bool _isLoading = true;

  @override
  Future<void> getRecipes(String searchText) async {
    _recipes = await RecipeApi.getRecipe(searchText);
    setState(() {
      _isLoading = false;
    });
    print(_recipes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu),
            SizedBox(width: 10),
            Text('Food Recipes'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controllersearch,
              decoration: InputDecoration(
                labelText: 'Search Recipes',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                getRecipes(value);
              },
            ),
          ),
          if (_isLoading == false)
            Expanded(
              child: ListView.builder(
                itemCount: _recipes.length,
                itemBuilder: (context, index) {
                  return RecipeCard(
                    title: _recipes[index].name,
                    thumbnailUrl: _recipes[index].image,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
