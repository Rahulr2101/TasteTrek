class Recipe {
  final String name;
  final String image;
  final String cal;
  final String yield;
  final String place;
  final List<dynamic> ingredient;
  final List<dynamic> ingimage;

  Recipe({
    required this.name,
    required this.image,
    required this.cal,
    required this.yield,
    required this.place,
    required this.ingredient,
    required this.ingimage,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'cal': cal,
      'yield': yield,
      'place': place,
      'ingredient': ingredient,
      'ingimage': ingimage,
    };
  }

  factory Recipe.fromJson(dynamic json) {
    double calorieValue =
        json['totalNutrients']['ENERC_KCAL']['quantity'] / json['yield'];
    String roundedCalorieString = calorieValue.toStringAsFixed(0);

    List<Map<String, dynamic>>? img =
        List<Map<String, dynamic>>.from(json['ingredients']);
    List<String> imgUrls = img?.map((img) {
          if (img != null && img.containsKey('image') && img['image'] != null) {
            return img['image'].toString();
          } else {
            return 'https://cdn.pixabay.com/photo/2017/02/12/21/29/false-2061131_1280.png';
          }
        }).toList() ??
        [];
    [];

    List<dynamic> ingredientsJson = json['ingredients'];
    List<String> ingredients = ingredientsJson.map((ingredientJson) {
      return ingredientJson['text'] as String;
    }).toList();

    return Recipe(
      name: json['label'] as String,
      image: json['image'] as String,
      cal: roundedCalorieString,
      yield: json['yield'].toString(),
      place: json['cuisineType'][0] as String,
      ingredient: ingredients,
      ingimage: imgUrls,
    );
  }

  static List<Recipe> recipeFromSnapshot(List<dynamic> snapshot) {
    return snapshot.map((data) {
      return Recipe.fromJson(data);
    }).toList();
  }
}
