import 'package:daily_recipes/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // supabase setup
  await Supabase.initialize(
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRvdGRvb2F1eG9mbHpiYnpoaGhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg4MjcwODIsImV4cCI6MjA1NDQwMzA4Mn0.M2kkzdRiTOlSXDgAubRJSc33QObdD5VrL3lJ4Z5iQ5A",
    url: "https://totdooauxoflzbbzhhhe.supabase.co",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
