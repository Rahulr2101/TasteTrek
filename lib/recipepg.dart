import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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
  late List<Recipe> _recipes = [];
  bool _isLoading = true;
  dynamic decodedResponse;
  List<dynamic> dishNames = [];
  List<String> rawImageUrl = [];

  @override
  Future<void> getRecipes(searchText) async {
    _recipes = await RecipeApi.getRecipe(searchText);
    setState(() {
      _isLoading = false;
    });
    print(_recipes);
  }

  // Future<void> fetchData() async {
  //   await fetchtreading();
  //   rawImageUrl = await fetchImages(); // Wait for fetchImages to complete
  // }

  Future<void> fetchDataFromApis() async {
    try {
      await fetchtreading();
      final resultPort = ReceivePort();
      final isolate =
          await Isolate.spawn(isolateimg, [resultPort.sendPort, dishNames]);
      rawImageUrl = await resultPort.first;
      // rawImageUrl = await fetchImages();
    } catch (e) {
      print('Error fetching data from APIs: $e');
    }
  }

  Future<void> fetchtreading() async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta2/models/chat-bison-001:generateMessage?key=AIzaSyALPProtKMsFmPpcDXRbs8EZvjEUssPQbw');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "prompt": {
        "examples": [
          {
            "input": {"content": "give 10 polpular dishes in json"},
            "output": {
              "content":
                  "json{\n \"dishes\": [\n   \"Pizza\",\n    \"Burger\",\n     \"Sushi\",\n   \"Tacos\",\n  \"Chicken Fried Rice\",\n  \"Tikka Masala\",\n   \"Pad Thai\",\n     \"Lasagna\",\n   \"Pho\"\n]\n}\n"
            }
          }
        ],
        "messages": [
          {"content": "give 10 polpular dishes in json  only names"}
        ]
      },
      "temperature": 0,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        dynamic jsonData = json.decode(response.body);
        print(jsonData);

        // Access the "candidates" key in the map
        List<dynamic> candidates = jsonData["candidates"];

        // Extract the content from the first element of candidates (assuming there's only one element)
        String content = candidates[0]["content"];

        // Extract the JSON array from the content string using regular expression
        RegExp regExp = RegExp(r'```json\n\s*(\[[\s\S]*\])\s*\n```');
        Match? match = regExp.firstMatch(content);
        if (match != null) {
          String jsonArrayString = match.group(1)!;
          dishNames = json.decode(jsonArrayString);
          print(dishNames);
        } else {
          print("JSON array not found in the content.");
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void navigateToRecipePage(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipePage(recipe: recipe),
      ),
    );
  }

  static final customCacheManager = CacheManager(Config(
    'customCacheKey',
    stalePeriod: const Duration(days: 15),
    maxNrOfCacheObjects: 100,
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.bottomCenter,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(10, 20, 0, 25),
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Find best recipes \nfor cooking",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 25),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 350,
                  height: 50,
                  child: TextField(
                    controller: controllersearch,
                    decoration: InputDecoration(
                      labelText: 'Search Recipes',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      getRecipes(value);
                    },
                  ),
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
                )
              else
                Column(children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      "Trending now",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: Colors.black),
                    ),
                  ),
                  FutureBuilder<void>(
                    future: fetchDataFromApis(),
                    builder: (context, snapshot) {
                      // Images are loaded successfully
                      return SizedBox(
                        height: 210,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(10),
                          itemCount: dishNames.length,
                          separatorBuilder: (context, index) {
                            return const SizedBox(width: 12);
                          },
                          itemBuilder: (context, index) => Stack(
                            children: [
                              CachedNetworkImage(
                                  key: UniqueKey(),
                                  cacheManager: customCacheManager,
                                  imageUrl: rawImageUrl[index],
                                  height: 250,
                                  width: 300,
                                  fit: BoxFit.cover),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(
                                        0.5), // Adjust the opacity as needed
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      dishNames[
                                          index], // Assuming dishNames contains the text for each image
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                ]),
            ],
          ),
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
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : decodedResponse != null && decodedResponse['candidates'] != null
                ? SafeArea(
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
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 0, 20, 0),
                                          child: Row(children: [
                                            Text(
                                              widget.recipe.name,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Expanded(
                                                child: GestureDetector(
                                              onTap: () =>
                                                  toggleFavorite(widget.recipe),
                                              child: Container(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Icon(Icons
                                                    .bookmark_border_outlined),
                                              ),
                                            ))
                                          ]),
                                        ),
                                      ),
                                      const SizedBox(
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
                                      const SizedBox(height: 10),
                                      Container(
                                        child: ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount:
                                              widget.recipe.ingredient.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Align(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    child: Image.network(
                                                      widget.recipe.ingimage[
                                                              index] ??
                                                          'https://cdn.pixabay.com/photo/2017/02/12/21/29/false-2061131_1280.png',
                                                      width: 40,
                                                      height: 40,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      widget.recipe
                                                          .ingredient[index],
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 0, 0, 0),
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
                                                  decodedResponse[
                                                          'candidates'] !=
                                                      null
                                              ? Container(
                                                  padding: EdgeInsets.all(16.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Instructions',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 8.0),
                                                      Text(
                                                        decodedResponse[
                                                                'candidates'][0]
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
                  )
                : Center(
                    child: Text(
                      'No instructions available',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ));
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

Future isolateimg(List<dynamic> args) async {
  SendPort responsePort = args[0];
  List<dynamic> dishNames = args[1];
  final apiKey = 'gEveQ1Hcp6c9LRQ_XZAlBSEsQvYzqd5aZ5vcDWcEaPk';
  List<String> imageUrlList = [];

  for (int i = 0; i < dishNames.length; i++) {
    final queryParameters = {
      'query': dishNames[i],
      'fit': 'crop',
      'w': '640', // Width in pixels (360p width)
      'h': '360', // Height in pixels (360p height)
    };
    final uri =
        Uri.https('api.unsplash.com', '/search/photos', queryParameters);
    final respon =
        await http.get(uri, headers: {'Authorization': 'Client-ID $apiKey'});
    if (respon.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(respon.body);
      List<dynamic> results = jsonData['results'];
      if (results.isNotEmpty) {
        imageUrlList.add(results[0]['urls']['raw']);
      }
    } else {
      // Handle the error when the API request fails
      print('Error: ${respon.statusCode}');
    }
  }
  print("Img links:$imageUrlList");

  Isolate.exit(responsePort, imageUrlList);
}
