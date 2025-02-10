import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:daily_recipes/pages/home_page_content.dart';

class AddRecipePage extends StatefulWidget {
  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  File? _imageFile;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _cookingTimeController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  bool _isUploading = false;

  Future<void> pickImage() async {
    try {
      // Meminta izin untuk mengakses foto
      // var status = await Permission.storage.request();
      // if (status.isGranted) {
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
      // } else {
      //   ScaffoldMessenger.of(context)
      //       .showSnackBar(SnackBar(content: Text('Permission denied.')));
      // }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> uploadRecipe() async {
    if (_imageFile == null ||
        _titleController.text.isEmpty ||
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
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final path = 'uploads/$fileName';

      final user = Supabase.instance.client.auth.currentUser;

      // Upload image to Supabase storage
      final uploadResponse = await Supabase.instance.client.storage
          .from('recipe_image') // nama bucketnya recipe_image
          .upload(path, _imageFile!);

      // Check for upload errors
      if (uploadResponse == false) {
        throw Exception('Error uploading image');
      }

      // Get the public URL of the uploaded image
      final imageUrl = Supabase.instance.client.storage
          .from('recipe_image')
          .getPublicUrl(path);

      // Insert recipe data into the database
      final insertResponse =
          await Supabase.instance.client.from('recipes').insert({
        'title': _titleController.text,
        'image_url': imageUrl,
        'cooking_time': int.parse(_cookingTimeController.text),
        'servings': int.parse(_servingsController.text),
        'ingredients': _ingredientsController.text,
        'instructions': _instructionsController.text,
        'id_user': user?.id,
      });

      // Check for insert errors
      if (insertResponse.error != null) {
        throw Exception(
            'Error inserting recipe: ${insertResponse.error!.message}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Recipe added successfully!')));

        // Navigate to the homepage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomePageContent()), // homepage widget
        );
      }
    } catch (e) {
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text('Error uploading recipe: $e')));
    } finally {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Recipe added successfully!')));
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Resep')),
      body: SingleChildScrollView(
        // Membuat konten dapat digulir
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 200,
                color: Colors.grey[300],
                child: _imageFile == null
                    ? Center(child: Text('Klik untuk menambahkan gambar'))
                    : Image.file(_imageFile!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Judul Resep'),
            ),
            TextField(
              controller: _cookingTimeController,
              decoration: InputDecoration(labelText: 'Waktu memasak (minutes)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _servingsController,
              decoration: InputDecoration(labelText: 'Porsi'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _ingredientsController,
              decoration: InputDecoration(labelText: 'Bahan-bahan'),
              maxLines: 3,
            ),
            TextField(
              controller: _instructionsController,
              decoration: InputDecoration(labelText: 'Cara Memasak'),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isUploading ? null : uploadRecipe,
              child: _isUploading
                  ? CircularProgressIndicator()
                  : Text('Upload Resep'),
            ),
          ],
        ),
      ),
    );
  }
}
