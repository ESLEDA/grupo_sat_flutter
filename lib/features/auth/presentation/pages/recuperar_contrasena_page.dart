import 'package:flutter/material.dart';

class RecuperarContrasenaPage extends StatelessWidget {
  const RecuperarContrasenaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8FF),
        title: const Text('Recuperar Contraseña'),
      ),
      body: const Center(
        child: Text(
          'Estoy en recuperar contraseña',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF193F6E),
          ),
        ),
      ),
    );
  }
}