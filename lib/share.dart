import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tastetrek/recipe.dart';

class Store {
  static late SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future<void> setBookmark(Recipe favbook) async {
    List<String> favorites = _preferences.getStringList('bookmark') ?? [];
    String itemJson = json.encode(favbook);
    bool isFavorite = favorites.contains(itemJson);
    if (isFavorite) {
      favorites.remove(itemJson);
    } else {
      favorites.add(itemJson);
    }

    await _preferences.setStringList('bookmark', favorites);
  }

  static List<String>? getBook() => _preferences.getStringList('bookmark');
}
