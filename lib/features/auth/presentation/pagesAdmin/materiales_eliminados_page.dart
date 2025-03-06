import 'package:flutter/material.dart';

class MaterialesEliminadosPage extends StatelessWidget {
  const MaterialesEliminadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materiales Eliminados'),
      ),
      body: const Center(
        child: Text(
          'Estoy en materiales eliminados',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

