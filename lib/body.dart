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

  void navigateToRecipePage(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipePage(recipe: recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.restaurant_menu),
            SizedBox(width: 10),
            Text('Tastetrek'),
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
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
                  return GestureDetector(
                    onTap: () {
                      navigateToRecipePage(_recipes[index]);
                    },
                    child: RecipeCard(
                      title: _recipes[index].name,
                      thumbnailUrl: _recipes[index].image,
                      cal: _recipes[index].cal,
                      place: _recipes[index].place,
                      ingredients: _recipes[index].ingredient,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class RecipePage extends StatelessWidget {
  final Recipe recipe;

  RecipePage({required this.recipe});

  @override
  Widget build(BuildContext context) {
    print(recipe.ingredient);
    return Scaffold(
        appBar: AppBar(
          title: Text(recipe.name),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              child: Stack(
                children: [
                  Positioned(
                      child: Container(
                    width: double.maxFinite,
                    height: 300,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(recipe.image),
                            fit: BoxFit.fitWidth)),
                  )),
                  Positioned(
                      top: 250,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 500,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30))),
                      )),
                  Positioned(
                      top: 280,
                      child: Column(
                        children: [
                          Container(
                            child: Text('Ingredients'),
                          ),
                          Container(
                            child: Text(recipe.ingredient),
                          )
                        ],
                      ))
                ],
              ),
            ),
          ),
        )
        // Build the recipe page UI using the recipe object
        );
  }
}
