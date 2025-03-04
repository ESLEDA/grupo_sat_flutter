import 'package:flutter/material.dart';

class MaterialesPage extends StatelessWidget {
  const MaterialesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materiales'),
      ),
      body: const Center(
        child: Text(
          'Estoy en la página de materiales',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}