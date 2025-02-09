import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecipeDetailPage extends StatelessWidget {
  final String title;
  final String imageUrl;
  final int cookingTime;
  final int servings;
  final String ingredients;
  final String instructions;
  final int recipeId;

  RecipeDetailPage({
    required this.title,
    required this.imageUrl,
    required this.cookingTime,
    required this.servings,
    required this.ingredients,
    required this.instructions,
    required this.recipeId,
  });

  Future<void> _saveRecipe(BuildContext context) async {
    // Mendapatkan ID pengguna yang sedang login
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You need to log in to save recipes.')),
      );
      return;
    }

    // Membuat objek untuk disimpan
    final savedRecipeData = {
      'id_recipe': recipeId, // ID resep
      'id_user': user.id, // ID pengguna
    };

    // Menyimpan data ke tabel saved_recipes
    final response = await Supabase.instance.client
        .from('saved_recipes')
        .insert(savedRecipeData);

    // if (response.error == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recipe saved!')),
    );

    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //         content: Text('Error saving recipe: ${response.error!.message}')),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // Logika untuk menyimpan resep
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text('Recipe saved!')),
              // );
              _saveRecipe(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Resep
              Image.network(imageUrl, fit: BoxFit.cover),

              SizedBox(height: 16.0),

              // Judul Resep
              Text(
                title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 8.0),

              // Waktu Memasak dan Porsi
              Text(
                'Waktu membuat: $cookingTime mins',
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 16.0),

              Text(
                'Porsi: $servings orang',
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 16.0),

              // Bahan
              Text(
                'Bahan-bahan:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(ingredients),

              SizedBox(height: 16.0),

              // Instruksi
              Text(
                'Cara Membuat:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(instructions),
            ],
          ),
        ),
      ),
    );
  }
}
