import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'perfil_page/perfil_administrador.dart';
import 'marcas_pages/marcas_page.dart';
import 'almacenes_page.dart';
import 'lista_adm_pages/lista_adm_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _nombreAdmin = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosAdmin();
  }

  Future<void> _cargarDatosAdmin() async {
    try {
      // Obtener el usuario actual autenticado
      final User? user = _auth.currentUser;
      if (user != null) {
        // Obtener datos del administrador desde Firestore
        final adminDoc = await _firestore
            .collection('administradores')
            .doc(user.uid)
            .get();

        if (adminDoc.exists) {
          setState(() {
            _nombreAdmin = adminDoc.data()?['nombreAdm'] ?? 'Administrador';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al cargar datos del administrador: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF444957),
      appBar: AppBar(
        title: _isLoading
            ? const Text('Cargando...')
            : Text('Hola $_nombreAdmin'),
        actions: [
          // Botón circular para ir al perfil
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF444957),
                  width: 2.0,
                ),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(
                    Icons.person,
                    color: Color(0xFF193F6E),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PerfilAdministradorPage(),
                      ),
                    ).then((_) {
                      // Recargar los datos cuando regrese del perfil
                      _cargarDatosAdmin();
                    });
                  },
                ),
              ),
            ),
          )
        ],
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
            // Botón de Marcas
            ListTile(
              leading: const Icon(Icons.label),
              title: const Text('Marcas'),
              onTap: () {
                // Cerrar el drawer
                Navigator.pop(context);
                // Navegar a la página de marcas
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MarcasPage(),
                  ),
                );
              },
            ),
            // Botón de Almacenes
            ListTile(
              leading: const Icon(Icons.warehouse),
              title: const Text('Almacenes'),
              onTap: () {
                // Cerrar el drawer
                Navigator.pop(context);
                // Navegar a la página de almacenes
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlmacenesPage(),
                  ),
                );
              },
            ),
            // Botón de Administradores
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Administradores'),
              onTap: () {
                // Cerrar el drawer
                Navigator.pop(context);
                // Navegar a la página de lista de administradores
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListaAdmPage(),
                  ),
                );
              },
            ),
            // Botón de Mi Perfil
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mi Perfil'),
              onTap: () {
                // Cerrar el drawer
                Navigator.pop(context);
                // Navegar a la página de perfil
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PerfilAdministradorPage(),
                  ),
                ).then((_) {
                  // Recargar los datos cuando regrese del perfil
                  _cargarDatosAdmin();
                });
              },
            ),
            const Divider(),
            // Botón de Cerrar Sesión
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                // Implementar lógica de cierre de sesión
                _auth.signOut();
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Image.asset(
            'assets/images/Sat.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}