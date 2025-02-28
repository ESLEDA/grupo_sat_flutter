import 'package:flutter/material.dart';
import 'registrar_admin_page.dart';

class ListaAdmPage extends StatelessWidget {
  const ListaAdmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text('Lista Administradores'),
        backgroundColor: const Color(0xFFF5F8FF),
      ),
      body: Column(
        children: [
          // Aquí puedes agregar la lista de administradores cuando la implementes
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Lista de Administradores',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF193F6E),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Este es el espacio donde irá la lista de administradores
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: const Center(
                child: Text(
                  'No hay administradores para mostrar /todo crear card',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // Botón flotante para agregar administrador
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navegar a la página de registro de administrador
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegistrarAdminPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Añadir Administrador'),
        backgroundColor: const Color(0xFF193F6E),
      ),
    );
  }
}