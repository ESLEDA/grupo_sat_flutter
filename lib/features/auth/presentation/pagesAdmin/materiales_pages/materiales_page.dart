import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../features/auth/presentation/bloc/marca_bloc.dart';
import 'registrar_material_page.dart';
import 'editar_material_page.dart';

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
      backgroundColor: const Color(0xFFF5F8FF),
      body: CustomScrollView(
        slivers: [
          // AppBar desplazable
          SliverAppBar(
            title: const Text('Lista de Materiales'),
            backgroundColor: const Color(0xFFF5F8FF),
            floating: true,
            pinned: true,
            snap: true,
            expandedHeight: 80,
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
            // Lista de cards de materiales con nuevo diseño similar a MarcasPage
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final material = _materiales[index];
                    final nombreMaterial = material['nombreMaterial'] ?? 'Material sin nombre';
                    final cantidad = material['cantidadUnidades'] ?? 0;
                    final marca = material['marcaMaterial'] ?? 'Sin marca';
                    final descripcion = material['descripcionMaterial'] ?? 'Sin descripción';
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        children: [
                          // Encabezado de la tarjeta con el nombre del material
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
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    _getInitial(nombreMaterial),
                                    style: const TextStyle(
                                      color: Color(0xFF193F6E),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Text(
                                    nombreMaterial,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Información del material
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.branding_watermark, size: 16, color: Colors.grey),
                                          const SizedBox(width: 8),
                                          Text('Marca: $marca'),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.inventory, size: 16, color: Colors.grey),
                                          const SizedBox(width: 8),
                                          Text('Cantidad: $cantidad ${cantidad == 1 ? 'unidad' : 'unidades'}'),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.description, size: 16, color: Colors.grey),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Descripción: $descripcion',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Botones de acción
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Botón de editar - Actualizado para navegar a EditarMaterialPage
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Color(0xFF193F6E)),
                                  onPressed: () async {
                                    // Cargar las marcas antes de navegar
                                    context.read<MarcaBloc>().add(LoadMarcas());
                                    
                                    // Navegar a la página de edición
                                    final resultado = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BlocProvider.value(
                                          value: BlocProvider.of<MarcaBloc>(context),
                                          child: EditarMaterialPage(material: material),
                                        ),
                                      ),
                                    );
                                    
                                    // Si vuelve con resultado, recargar los materiales
                                    if (resultado == true) {
                                      _cargarMateriales();
                                    }
                                  },
                                ),
                                // Botón de eliminar
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Eliminar material'),
                                        content: Text('¿Está seguro de eliminar el material $nombreMaterial?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              
                                              try {
                                                await _firestore.collection('materiales').doc(material['id'].toString()).delete();
                                                
                                                if (!mounted) return;
                                                
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Material eliminado con éxito'),
                                                    backgroundColor: Colors.green,
                                                  ),
                                                );
                                                
                                                _cargarMateriales();
                                              } catch (e) {
                                                if (!mounted) return;
                                                
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Error al eliminar material: $e'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
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