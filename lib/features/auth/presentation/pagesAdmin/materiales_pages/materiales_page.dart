import 'package:flutter/material.dart';
import 'registrar_material_page.dart';

class MaterialesPage extends StatelessWidget {
  const MaterialesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materiales'),
        actions: [
          // Botón para agregar nuevo material
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegistrarMaterialPage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Nuevo Material'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF193F6E),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16), // Espacio al final
        ],
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