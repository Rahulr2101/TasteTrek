import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'body.dart';
import 'home.dart';
import 'recipe.dart';
import 'recipe.api.dart';
import 'share.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controllersearch = TextEditingController();
  late List<Recipe> _recipes;
  bool _isLoading = true;

  @override
  Future<void> getRecipes(searchText) async {
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
      body: Container(
        alignment: Alignment.bottomCenter,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: controllersearch,
                decoration: InputDecoration(
                  labelText: 'Search Recipes',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
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
                        ingimage: _recipes[index].ingimage,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class RecipePage extends StatefulWidget {
  final Recipe recipe;

  RecipePage({required this.recipe});

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  dynamic decodedResponse;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta2/models/chat-bison-001:generateMessage?key=AIzaSyALPProtKMsFmPpcDXRbs8EZvjEUssPQbw');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "prompt": {
        "examples": [
          {
            "input": {
              "content": "How to make chicken curry only instructions to make."
            },
            "output": {
              "content":
                  "Instruction,1. boil water\n2. cook chicken\n3. fry chicken in oil till it becomes brown"
            }
          }
        ],
        "messages": [
          {
            "content":
                "How to ${widget.recipe.name} give only instructions to make don't give ingredients"
          }
        ]
      },
      "temperature": 1,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        decodedResponse = json.decode(response.body);
        print(decodedResponse);
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void toggleFavorite(Recipe recipe) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];
    String itemJson = json.encode(recipe.toJson());
    bool isFavorite = favorites.contains(itemJson);
    if (isFavorite) {
      favorites.remove(itemJson);
    } else {
      favorites.add(itemJson);
    }
    await prefs.setStringList('favorites', favorites);
    print(favorites);
  }

  @override
  Widget build(BuildContext context) {
    print(widget.recipe.ingredient);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.name),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(color: Colors.white),
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
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.35),
                          BlendMode.multiply,
                        ),
                        image: NetworkImage(widget.recipe.image),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 250,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 500,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 280,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Align(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              widget.recipe.name,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Text(
                            'Ingredients',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: widget.recipe.ingredient.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Image.network(
                                          widget.recipe.ingimage[index] ??
                                              'https://cdn.pixabay.com/photo/2017/02/12/21/29/false-2061131_1280.png',
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          widget.recipe.ingredient[index],
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 0, 0, 0),
                                          ),
                                        ),
                                      ),
                                      // ElevatedButton(
                                      //   onPressed: () {
                                      //     toggleFavorite(widget.recipe);
                                      //   },
                                      //   child: Text('Save'),
                                      // )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          // Displaying the decodedResponse or loading indicator
                          _isLoading
                              ? CircularProgressIndicator()
                              : decodedResponse != null &&
                                      decodedResponse['candidates'] != null
                                  ? Container(
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Instructions',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            decodedResponse['candidates'][0]
                                                ['content'],
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'No instructions available',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
