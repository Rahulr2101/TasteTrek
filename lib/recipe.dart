class Recipe {
  final String name;
  final String image;
  final String cal;
  final String yield;
  final String place;
  final List<dynamic> ingredient;
  final List<dynamic> ingimage;

  Recipe(
      {required this.name,
      required this.image,
      required this.cal,
      required this.yield,
      required this.place,
      required this.ingredient,
      required this.ingimage});

  factory Recipe.fromJson(dynamic json) {
    double calorieValue =
        json['totalNutrients']['ENERC_KCAL']['quantity'] / json['yield'];
    String roundedCalorieString = calorieValue.toStringAsFixed(0);

    List<Map<String, dynamic>> img =
        List<Map<String, dynamic>>.from(json['ingredients']);
    List<String> imgUrls = img.map((img) {
      return img['image'] as String;
    }).toList();

    List<dynamic> ingredientsJson = json['ingredients'];
    List<String> ingredients = ingredientsJson.map((ingredientJson) {
      return ingredientJson['text'] as String;
    }).toList();

    return Recipe(
        name: json['label'] as String,
        image: json['image'] as String,
        cal: roundedCalorieString,
        yield: json['yield'].toString(),
        place: json['cuisineType'][0],
        ingredient: ingredients,
        ingimage: imgUrls);
  }

  static List<Recipe> recipeFromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return Recipe.fromJson(data);
    }).toList();
  }
}
