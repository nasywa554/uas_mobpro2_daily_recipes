class RecipeModel {
  final String id; // ID resep
  final String title; // Judul resep
  final String imageUrl; // URL gambar resep
  final String ingredients; // Bahan-bahan resep
  final String instructions; // Cara membuat resep
  final int cookingTime; // Waktu memasak dalam menit
  final int servings; // Jumlah porsi
  final String userId; // ID pengguna yang membagikan resep

  RecipeModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.ingredients,
    required this.instructions,
    required this.cookingTime,
    required this.servings,
    required this.userId,
  });

  // Metode untuk mengonversi dari Map ke RecipeModel
  factory RecipeModel.fromMap(Map<String, dynamic> data) {
    return RecipeModel(
      id: data['id'] as String,
      title: data['title'] as String,
      imageUrl: data['image_url'] as String,
      ingredients: data['ingredients'] as String,
      instructions: data['instructions'] as String,
      cookingTime: data['cooking_time'] as int,
      servings: data['servings'] as int,
      userId: data['user_id'] as String,
    );
  }

  // Metode untuk mengonversi dari RecipeModel ke Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'ingredients': ingredients,
      'instructions': instructions,
      'cooking_time': cookingTime,
      'servings': servings,
      'user_id': userId,
    };
  }
}
