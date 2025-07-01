import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../dummy/dummy_menu_data.dart';

class SeedMenuPage extends StatefulWidget {
  const SeedMenuPage({super.key});

  @override
  State<SeedMenuPage> createState() => _SeedMenuPageState();
}

class _SeedMenuPageState extends State<SeedMenuPage> {
  Future<void> seedToFirestore() async {
    final menuCollection = FirebaseFirestore.instance.collection('menu');

    for (final menu in dummyMenuList) {
      await menuCollection.add(menu);
    }

    if (!mounted) return; // pastikan widget masih ada di tree

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Seeding data berhasil!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seed Menu')),
      body: Center(
        child: ElevatedButton(
          onPressed: seedToFirestore,
          child: const Text('Seed Data Dummy ke Firestore'),
        ),
      ),
    );
  }
}
