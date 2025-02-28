import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'registrar_admin_page.dart';

class ListaAdmPage extends StatefulWidget {
  const ListaAdmPage({super.key});

  @override
  State<ListaAdmPage> createState() => _ListaAdmPageState();
}

class _ListaAdmPageState extends State<ListaAdmPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _administradores = [];

  @override
  void initState() {
    super.initState();
    _cargarAdministradores();
  }

  Future<void> _cargarAdministradores() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Obtener documentos de la colección 'administradores'
      final QuerySnapshot snapshot = await _firestore.collection('administradores').get();
      
      // Convertir documentos a lista de mapas
      final List<Map<String, dynamic>> administradores = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
      
      setState(() {
        _administradores = administradores;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar administradores: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text('Lista de Administradores'),
        backgroundColor: const Color(0xFFF5F8FF),
      ),
      body: Column(
        children: [
          
          
          const SizedBox(height: 20),
          // Lista de administradores
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _administradores.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay administradores registrados',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _cargarAdministradores,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _administradores.length,
                          itemBuilder: (context, index) {
                            final admin = _administradores[index];
                            return AdminCard(admin: admin);
                          },
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
          ).then((_) {
            // Recargar la lista cuando vuelva
            _cargarAdministradores();
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Añadir Administrador'),
        backgroundColor: const Color(0xFF193F6E),
      ),
    );
  }
}

class AdminCard extends StatelessWidget {
  final Map<String, dynamic> admin;

  const AdminCard({
    super.key,
    required this.admin,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener datos del administrador
    final String nombre = admin['nombreAdm'] ?? '';
    final String primerApellido = admin['primerApellidoAdm'] ?? '';
    final String? segundoApellido = admin['segundoApellidoAdm'];
    final String celular = admin['celularAdm'] ?? '';
    final String correo = admin['correoAdm'] ?? '';
    
    // Construir nombre completo
    final String nombreCompleto = segundoApellido != null && segundoApellido.isNotEmpty
        ? '$nombre $primerApellido $segundoApellido'
        : '$nombre $primerApellido';

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          // Contenedor superior con nombre
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Color(0xFF193F6E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: Color(0xFF193F6E),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    nombreCompleto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Contenedor inferior con datos
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información de contacto
                Row(
                  children: [
                    const Icon(Icons.email, size: 20, color: Color(0xFF193F6E)),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        correo,
                        style: const TextStyle(fontSize: 14.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 20, color: Color(0xFF193F6E)),
                    const SizedBox(width: 8.0),
                    Text(
                      celular,
                      style: const TextStyle(fontSize: 14.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}