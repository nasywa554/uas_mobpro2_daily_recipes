import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'package:daily_recipes/pages/saved_recipes_page.dart'; // Pastikan untuk mengimpor SavedRecipesPage
import 'package:daily_recipes/pages/add_recipe_page.dart'; // Pastikan untuk mengimpor AddRecipePage
import 'package:daily_recipes/pages/profile_page.dart'; // Pastikan untuk mengimpor ProfilePage
import 'package:daily_recipes/pages/home_page_content.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseService supabaseService = SupabaseService();
  int _selectedIndex = 0;

  late final List<Widget>
      _widgetOptions; // Gunakan 'late' untuk menunda inisialisasi

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomePageContent(), // Ganti dengan widget HomePageContent
      SavedRecipesPage(), // Halaman Simpan
      AddRecipePage(), // Halaman Tambah
      ProfilePage(), // Halaman Profile
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Recipes')),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Simpan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Tambah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Warna ikon yang dipilih
        unselectedItemColor: Colors.grey, // Warna ikon yang tidak dipilih
        onTap: _onItemTapped,
      ),
    );
  }
}
