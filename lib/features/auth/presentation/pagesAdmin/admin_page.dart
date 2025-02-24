import 'package:flutter/material.dart';
import 'registrar_admin_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista Administrador'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 35,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Panel de Administrador',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Registrar Administrador'),
              onTap: () {
                // Cerrar el drawer
                Navigator.pop(context);
                // Navegar a la página de registro de administrador
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegistrarAdminPage(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                // Implementar lógica de cierre de sesión
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Bienvenido, Administrador',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}