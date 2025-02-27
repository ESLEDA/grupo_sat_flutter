import 'package:flutter/material.dart';

class MarcasPage extends StatelessWidget {
  const MarcasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text('Marcas'),
        backgroundColor: const Color(0xFFF5F8FF),
      ),
      body: const Center(
        child: Text(
          'Página de Marcas',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF193F6E),
          ),
        ),
      ),
    );
  }
}