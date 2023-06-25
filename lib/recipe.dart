class Recipe {
  final String name;
  final String image;

  Recipe({required this.name, required this.image});

  factory Recipe.fromJson(dynamic json) {
    return Recipe(
        name: json['label'] as String, image: json['image'] as String);
  }

  static List<Recipe> recipeFromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return Recipe.fromJson(data);
    }).toList();
  }
}
