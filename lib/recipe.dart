class Recipe {
  final String name;
  final String image;
  final String cal;
  final String yield;
  final String place;

  Recipe(
      {required this.name,
      required this.image,
      required this.cal,
      required this.yield,
      required this.place});

  factory Recipe.fromJson(dynamic json) {
    double calorieValue =
        json['totalNutrients']['ENERC_KCAL']['quantity'] / json['yield'];
    String roundedCalorieString = calorieValue.toStringAsFixed(0);
    return Recipe(
        name: json['label'] as String,
        image: json['image'] as String,
        cal: roundedCalorieString,
        yield: json['yeild'].toString(),
        place: json['cuisineType'][0]);
  }

  static List<Recipe> recipeFromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return Recipe.fromJson(data);
    }).toList();
  }
}
