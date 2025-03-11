import 'package:flutter/material.dart';

class PrestarMaterialPage extends StatefulWidget {
  const PrestarMaterialPage({super.key});

  @override
  State<PrestarMaterialPage> createState() => _PrestarMaterialPageState();
}

class _PrestarMaterialPageState extends State<PrestarMaterialPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text('Préstamo de Material'),
        backgroundColor: const Color(0xFFF5F8FF),
      ),
      body: const Center(
        child: Text(
          'Estoy en préstamo material',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF193F6E),
          ),
        ),
      ),
    );
  }
}