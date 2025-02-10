import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'recipe_detail_page.dart'; // Pastikan untuk mengimpor halaman detail resep

class SavedRecipesPage extends StatefulWidget {
  @override
  _SavedRecipesPageState createState() => _SavedRecipesPageState();
}

class _SavedRecipesPageState extends State<SavedRecipesPage> {
  List<Map<String, dynamic>> savedRecipes = [];

  @override
  void initState() {
    super.initState();
    _fetchSavedRecipes(); // Ambil data resep yang disimpan saat halaman dibuka
  }

  Future<void> _fetchSavedRecipes() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('User  is not logged in');
    }
    final String userId = user.id;
    final response = await Supabase.instance.client
        .from('saved_recipes') 
        .select('id_recipe, id_user')
        .eq('id_user', userId);

    final List<dynamic> savedRecipeData = response; // Ambil data dari response
    for (var item in savedRecipeData) {
      final recipeResponse = await Supabase.instance.client
          .from('recipes') 
          .select('*') // Ambil semua kolom
          .eq('id', item['id_recipe']);

      savedRecipes.add(recipeResponse[0]); // Tambahkan resep ke list
    }
    setState(() {}); // Memperbarui UI setelah data diambil
  }

  Future<void> _deleteSavedRecipe(int recipeId) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      // Hapus resep dari tabel saved_recipes
      final response = await Supabase.instance.client
          .from('saved_recipes') 
          .delete()
          .eq('id_recipe', recipeId)
          .eq('id_user',
              user.id); // untuk menghapus berdasarkan id_user

      // if (response.error == null) {
      setState(() {
        savedRecipes.removeWhere((recipe) => recipe['id'] == recipeId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recipe removed from saved recipes!')),
      );
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //         content:
      //             Text('Error removing recipe: ${response.error!.message}')),
      //   );
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resep Tersimpan'),
      ),
      body: savedRecipes.isEmpty
          ? Center(
              child: Text(
                  'No saved recipes found.')) // Menampilkan pesan jika tidak ada resep yang disimpan
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Jumlah kolom
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: savedRecipes.length,
              itemBuilder: (context, index) {
                final recipe = savedRecipes[index];
                return GestureDetector(
                  onTap: () {
                    // Navigasi ke halaman detail resep saat resep tersimpan diklik
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailPage(
                          title: recipe['title'],
                          imageUrl: recipe['image_url'],
                          cookingTime: recipe['cooking_time'],
                          servings: recipe['servings'],
                          ingredients: recipe['ingredients'],
                          instructions: recipe['instructions'],
                          recipeId: recipe['id'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Image.network(
                            recipe['image_url'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe['title'],
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Cooking Time: ${recipe['cooking_time']} mins',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Servings: ${recipe['servings']}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        // tombol hapus di bawah resep
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteSavedRecipe(recipe['id']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
