import 'package:flutter/material.dart';
// presentation/pages/empleado_page.dart
class EmpleadoPage extends StatelessWidget {
  const EmpleadoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vista Empleado')),
      body: const Center(
        child: Text('Bienvenido, Empleado'),
      ),
    );
  }
}
