import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _imageFile;
  String? username;
  String? name;

  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();

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
          .from('user_photo') 
          .select('username, name, photo')
          .eq('id_user', user.id);

      // if (response.error == null && response.data.isNotEmpty) {
      final userData = response[0];
      setState(() {
        username = userData['username'] ?? '';
        name = userData['name'] ?? '';
        _usernameController.text = username!;
        _nameController.text = name!;
      });
      // }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      // Upload image if selected
      String? imagePath;
      if (_imageFile != null) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final path = 'uploads/$fileName';
        final response = await Supabase.instance.client.storage
            .from('user_photo') // Ganti dengan nama bucket Anda
            .upload(path, _imageFile!);

        // if (response == null) {
        imagePath = path;
        // } else {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('Error uploading image: ${response}')),
        //   );
        //   return;
        // }
      }

      // Update user profile
      final updateResponse = await Supabase.instance.client
          .from('user_photo') // Ganti dengan nama tabel Anda
          .update({
        'username': _usernameController.text,
        'name': _nameController.text,
        if (imagePath != null)
          'photo': Supabase.instance.client.storage
              .from('user_photo')
              .getPublicUrl(imagePath),
      }).eq('id_user', user.id);

      // if (updateResponse.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context);
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //         content: Text(
      //             'Error updating profile: ${updateResponse.error!.message}')),
      //   );
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null
                    ? Icon(Icons.camera_alt, size: 50)
                    : null,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
