import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:daily_recipes/pages/edit_profile_page.dart';
import 'package:daily_recipes/pages/edit_recipe_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? photoUrl;
  String? name;
  String? username;
  String? email;
  List<Map<String, dynamic>> uploadedRecipes = [];

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      // Ambil data pengguna dari tabel user_photo
      final response = await Supabase.instance.client
          .from('user_photo') // Ganti dengan nama tabel Anda
          .select('photo, name, username')
          .eq('id_user', user.id);

      final userData = response[0];
      setState(() {
        photoUrl = userData['photo'];
        name = userData['name'];
        username = userData['username'];
        email = user.email;
      });

      // Ambil resep yang diupload oleh pengguna
      _fetchUploadedRecipes(user.id);
    }
  }

  Future<void> _fetchUploadedRecipes(String userId) async {
    final response = await Supabase.instance.client
        .from('recipes') // Ganti dengan nama tabel resep Anda
        .select('*')
        .eq('id_user', userId);

    setState(() {
      uploadedRecipes = List<Map<String, dynamic>>.from(response);
    });
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(),
      ),
    ).then((_) {
      // Setelah kembali dari EditProfilePage, ambil data pengguna lagi
      _fetchUser();
    });
  }

  void _editRecipe(
      int recipeId,
      String currentTitle,
      String currentImageUrl,
      int currentCookingTime,
      int currentServings,
      String currentIngredients,
      String currentInstructions) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRecipePage(
          recipeId: recipeId,
          currentTitle: currentTitle,
          currentImageUrl: currentImageUrl,
          currentCookingTime: currentCookingTime,
          currentServings: currentServings,
          currentIngredients: currentIngredients,
          currentInstructions: currentInstructions,
        ),
      ),
    );
  }

  void _deleteRecipe(int recipeId) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      // Hapus referensi di tabel saved_recipes
      final deleteSavedResponse = await Supabase.instance.client
          .from('saved_recipes') // Ganti dengan nama tabel saved_recipes Anda
          .delete()
          .eq('id_recipe', recipeId);

      // Hapus resep dari tabel recipes
      final response = await Supabase.instance.client
          .from('recipes') // Ganti dengan nama tabel resep Anda
          .delete()
          .eq('id', recipeId);

      setState(() {
        uploadedRecipes.removeWhere((recipe) => recipe['id'] == recipeId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recipe deleted successfully!')),
      );
    }
  }

  void _logout() async {
    await Supabase.instance.client.auth.signOut();
    Navigator.of(context)
        .pushReplacementNamed('/login'); // Ganti dengan rute login Anda
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$name\'s Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  photoUrl != null ? NetworkImage(photoUrl!) : null,
              child: photoUrl == null ? Icon(Icons.person, size: 50) : null,
            ),
            SizedBox(height: 16),
            Text(
              name ?? 'Loading...',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '@$username',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              email ?? 'Loading...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _editProfile,
              child: Text('Edit Profile'),
            ),
            SizedBox(height: 20),
            Text(
              'Uploaded Recipes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: uploadedRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = uploadedRecipes[index];
                  return ListTile(
                    title: Text(recipe['title']),
                    subtitle:
                        Text('Cooking Time: ${recipe['cooking_time']} mins'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editRecipe(
                            recipe['id'],
                            recipe['title'],
                            recipe['image_url'],
                            recipe['cooking_time'],
                            recipe['servings'],
                            recipe['ingredients'],
                            recipe['instructions'],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteRecipe(recipe['id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
