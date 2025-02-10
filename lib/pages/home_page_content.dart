import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:daily_recipes/pages/recipe_detail_page.dart';

class HomePageContent extends StatefulWidget {
  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _recipes = [];

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    final response = await Supabase.instance.client.from('recipes').select();
    // print(response);
    // if (response.error == null) {
    setState(() {
      _recipes = List<Map<String, dynamic>>.from(response);
    });
    // } else {
    //   print('Error fetching recipes: ${response.error!.message}');
    // }
  }

  void _filterRecipes(String query) {
    setState(() {
      _recipes = _recipes
          .where((recipe) =>
              recipe['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _filterRecipes,
            decoration: InputDecoration(
              labelText: 'Search Recipes',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        // GridView of recipes
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: _recipes.length,
            itemBuilder: (context, index) {
              final recipe = _recipes[index];

              return GestureDetector(
                onTap: () {
                  // Navigasi ke halaman detail resep
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
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
