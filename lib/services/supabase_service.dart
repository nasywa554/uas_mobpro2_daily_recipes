import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getRecipes() async {
    final response = await supabase.from('recipes').select();
    return response;
  }

  Future<void> addRecipe(
      String title, String ingredients, String steps, File image) async {
    final imagePath = 'recipes/${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Upload gambar ke Supabase Storage
    await supabase.storage.from('recipes').upload(imagePath, image);
    final imageUrl = supabase.storage.from('recipes').getPublicUrl(imagePath);

    await supabase.from('recipes').insert({
      'title': title,
      'ingredients': ingredients,
      'steps': steps,
      'imagePath': imageUrl,
    });
  }
}
