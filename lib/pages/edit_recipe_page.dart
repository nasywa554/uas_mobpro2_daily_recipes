import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditRecipePage extends StatefulWidget {
  final int recipeId;
  final String currentTitle;
  final String currentImageUrl;
  final int currentCookingTime;
  final int currentServings;
  final String currentIngredients;
  final String currentInstructions;

  EditRecipePage({
    required this.recipeId,
    required this.currentTitle,
    required this.currentImageUrl,
    required this.currentCookingTime,
    required this.currentServings,
    required this.currentIngredients,
    required this.currentInstructions,
  });

  @override
  _EditRecipePageState createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  File? _imageFile;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _cookingTimeController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Mengisi controller dengan data yang ada
    _titleController.text = widget.currentTitle;
    _cookingTimeController.text = widget.currentCookingTime.toString();
    _servingsController.text = widget.currentServings.toString();
    _ingredientsController.text = widget.currentIngredients;
    _instructionsController.text = widget.currentInstructions;
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No image selected.')));
    }
  }

  Future<void> updateRecipe() async {
    if (_titleController.text.isEmpty ||
        _cookingTimeController.text.isEmpty ||
        _servingsController.text.isEmpty ||
        _ingredientsController.text.isEmpty ||
        _instructionsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please fill in all fields and select an image.')));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String? imageUrl;

      // Jika ada gambar baru, upload gambar tersebut
      if (_imageFile != null) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final path = 'uploads/$fileName';

        // Upload image to Supabase storage
        final uploadResponse = await Supabase.instance.client.storage
            .from(
                'recipe_image') 
            .upload(path, _imageFile!);

        // Check for upload errors
        // if (uploadResponse != null) {
        //   throw Exception('Error uploading image: ${uploadResponse.error!.message}');
        // }

        // Get the public URL of the uploaded image
        imageUrl = Supabase.instance.client.storage
            .from('recipe_image')
            .getPublicUrl(path);
      } else {
        // Jika tidak ada gambar baru, gunakan gambar yang sudah ada
        imageUrl = widget.currentImageUrl;
      }

      // Update recipe data in the database
      final updateResponse =
          await Supabase.instance.client.from('recipes').update({
        'title': _titleController.text,
        'image_url': imageUrl,
        'cooking_time': int.parse(_cookingTimeController.text),
        'servings': int.parse(_servingsController.text),
        'ingredients': _ingredientsController.text,
        'instructions': _instructionsController.text,
      }).eq('id', widget.recipeId); // Update berdasarkan ID resep

      // Check for update errors
      // if (updateResponse.error != null) {
      //   throw Exception(
      //       'Error updating recipe: ${updateResponse.error!.message}');
      // } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recipe updated successfully!')));
      Navigator.pop(context); // Kembali ke halaman sebelumnya
      // }
    } catch (e) {
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text('Error updating recipe: $e')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Recipe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 200,
                color: Colors.grey[300],
                child: _imageFile == null
                    ? Image.network(widget.currentImageUrl, fit: BoxFit.cover)
                    : Image.file(_imageFile!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Recipe Title'),
            ),
            TextField(
              controller: _cookingTimeController,
              decoration: InputDecoration(labelText: 'Cooking Time (minutes)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _servingsController,
              decoration: InputDecoration(labelText: 'Servings'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _ingredientsController,
              decoration: InputDecoration(labelText: 'Ingredients'),
              maxLines: 3,
            ),
            TextField(
              controller: _instructionsController,
              decoration: InputDecoration(labelText: 'Instructions'),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isUploading ? null : updateRecipe,
              child: _isUploading
                  ? CircularProgressIndicator()
                  : Text('Update Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
