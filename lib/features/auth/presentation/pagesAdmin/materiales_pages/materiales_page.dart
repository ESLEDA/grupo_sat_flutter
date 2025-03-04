import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../features/auth/presentation/bloc/marca_bloc.dart';
import 'registrar_material_page.dart';

class MaterialesPage extends StatefulWidget {
  const MaterialesPage({super.key});

  @override
  State<MaterialesPage> createState() => _MaterialesPageState();
}

class _MaterialesPageState extends State<MaterialesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _materiales = [];
  String _errorMessage = '';
  
  // Método seguro para obtener la inicial de un nombre
  String _getInitial(String? nombre) {
    if (nombre == null || nombre.isEmpty) {
      return 'M';
    }
    return nombre.substring(0, 1).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _cargarMateriales();
  }

  Future<void> _cargarMateriales() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final materialesSnapshot = await _firestore.collection('materiales').get();
      
      setState(() {
        _materiales = materialesSnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Agregar el ID del documento
          return data;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar materiales: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar desplazable
          SliverAppBar(
            title: const Text('Lista de Materiales'),
            floating: true, // Aparece cuando se desplaza hacia arriba
            pinned: true, // El título permanece visible al desplazarse
            snap: true, // Vuelve a aparecer completo cuando se comienza a desplazar hacia arriba
            expandedHeight: 80, // Altura expandida
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                alignment: Alignment.center,
               
                
              ),
            ),
          ),
          
          // Botón para agregar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Cargar las marcas antes de navegar
                  context.read<MarcaBloc>().add(LoadMarcas());
                  
                  // Navegar usando BlocProvider.value para pasar el MarcaBloc
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: BlocProvider.of<MarcaBloc>(context),
                        child: const RegistrarMaterialPage(),
                      ),
                    ),
                  ).then((_) {
                    // Recargar los materiales al volver
                    _cargarMateriales();
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Nuevo Material'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF193F6E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ),
            ),
          ),
          
          // Mostrar mensajes de error o carga
          if (_errorMessage.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_materiales.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'No hay materiales registrados',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            // Lista de cards de materiales
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final material = _materiales[index];
                    final cantidad = material['cantidadUnidades'] ?? 0;
                    final marca = material['marcaMaterial'] ?? 'Sin marca';
                    final descripcion = material['descripcionMaterial'] ?? 'Sin descripción';
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF193F6E),
                          child: Text(
                            _getInitial(material['nombreMaterial']),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          material['nombreMaterial'] ?? 'Material sin nombre',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Marca: $marca'),
                            Text('Cantidad: $cantidad ${cantidad == 1 ? 'unidad' : 'unidades'}'),
                            const SizedBox(height: 2),
                            Text(
                              'Descripción: $descripcion',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _materiales.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}