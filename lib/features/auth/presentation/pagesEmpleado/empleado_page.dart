import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'perfil_empleado.dart';

class EmpleadoPage extends StatefulWidget {
  const EmpleadoPage({super.key});

  @override
  State<EmpleadoPage> createState() => _EmpleadoPageState();
}

class _EmpleadoPageState extends State<EmpleadoPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _nombreEmpleado = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosEmpleado();
  }

  Future<void> _cargarDatosEmpleado() async {
    try {
      // Obtener el usuario actual autenticado
      final User? user = _auth.currentUser;
      if (user != null) {
        // Obtener datos del empleado desde Firestore
        final empleadoDoc = await _firestore
            .collection('empleados')
            .doc(user.uid)
            .get();

        if (empleadoDoc.exists) {
          setState(() {
            _nombreEmpleado = empleadoDoc.data()?['nombreEmpleado'] ?? 'Empleado';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al cargar datos del empleado: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF193F6E),
      appBar: AppBar(
        title: _isLoading
            ? const Text('Cargando...')
            : Text('Hola $_nombreEmpleado'),
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
                        builder: (context) => const PerfilEmpleadoPage(),
                      ),
                    ).then((_) {
                      // Recargar los datos cuando regrese del perfil
                      _cargarDatosEmpleado();
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
                      Icons.person,
                      size: 35,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Panel de Empleado',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
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
                    builder: (context) => const PerfilEmpleadoPage(),
                  ),
                ).then((_) {
                  // Recargar los datos cuando regrese del perfil
                  _cargarDatosEmpleado();
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