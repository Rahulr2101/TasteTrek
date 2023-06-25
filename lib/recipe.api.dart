import 'package:tastetrek/recipe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeApi {
  static Future<List<Recipe>> getRecipe(searchText) async {
    print('data');
    final url =
        'https://api.edamam.com/search?q=$searchText&app_id=52f1e434&app_key=dfbc1dbae383fc5f5b68ab38f84d24ba';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final json = jsonDecode(response.body);
    var hits = json['hits'];

    List _temp = [];
    for (var i in hits) {
      _temp.add(i['recipe']);
    }
    print(_temp);
    return Recipe.recipeFromSnapshot(_temp);
  }
}
