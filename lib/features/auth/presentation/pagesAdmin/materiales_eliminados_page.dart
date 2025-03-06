import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialesEliminadosPage extends StatefulWidget {
  const MaterialesEliminadosPage({super.key});

  @override
  State<MaterialesEliminadosPage> createState() => _MaterialesEliminadosPageState();
}

class _MaterialesEliminadosPageState extends State<MaterialesEliminadosPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _materialesEliminados = [];
  String _errorMessage = '';
  
  

  @override
  void initState() {
    super.initState();
    _cargarMaterialesEliminados();
  }

  Future<void> _cargarMaterialesEliminados() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Obtener documentos de la colección 'materialesEliminados'
      final materialesSnapshot = await _firestore.collection('materialesEliminados').get();
      
      setState(() {
        _materialesEliminados = materialesSnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Agregar el ID del documento
          return data;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar materiales eliminados: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8FF),
        title: const Text('Materiales Eliminados'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarMaterialesEliminados,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _materialesEliminados.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay materiales eliminados',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _cargarMaterialesEliminados,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _materialesEliminados.length,
                        itemBuilder: (context, index) {
                          final material = _materialesEliminados[index];
                          return MaterialEliminadoCard(material: material);
                        },
                      ),
                    ),
    );
  }
}

class MaterialEliminadoCard extends StatelessWidget {
  final Map<String, dynamic> material;

  const MaterialEliminadoCard({
    super.key,
    required this.material,
  });

  @override
  Widget build(BuildContext context) {
    // Extraer información del material eliminado
    final String nombre = material['nombreMaterial'] ?? 'Sin nombre';
    final String marca = material['marcaMaterial'] ?? 'Sin marca';
    final int cantidad = material['cantidadUnidades'] ?? 0;
    final String descripcion = material['descripcionMaterial'] ?? 'Sin descripción';
    final Timestamp? fechaEliminacion = material['fechaEliminacion'] as Timestamp?;
    
    // Formatear la fecha si existe
    String fechaTexto = 'Fecha desconocida';
    if (fechaEliminacion != null) {
      final fecha = fechaEliminacion.toDate();
      fechaTexto = '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
    }

    

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
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.inventory,
                    color: Color(0xFF193F6E),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    nombre,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Detalles del material
                _buildInfoRow(Icons.branding_watermark, 'Marca', marca),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.inventory, 'Cantidad', '$cantidad ${cantidad == 1 ? 'unidad' : 'unidades'}'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.delete_outline, 'Eliminado', fechaTexto),
                const SizedBox(height: 12),
                
                // Descripción
                const Text(
                  'Descripción:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  style: const TextStyle(fontSize: 14),
                ),
                
                // Si hay números de serie, mostrarlos
                if (material['numeroSerie'] != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Números de Serie:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildSerialNumbers(material['numeroSerie']),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para construir una fila de información
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Widget para mostrar los números de serie
  Widget _buildSerialNumbers(Map<String, dynamic>? seriales) {
    if (seriales == null || seriales.isEmpty) {
      return const Text('No hay números de serie registrados');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: seriales.entries.map((entry) {
        
        final Map<String, dynamic> datos = entry.value is Map<String, dynamic> 
            ? entry.value as Map<String, dynamic> 
            : {'serie': 'Desconocido', 'unidad': 'Desconocido'};
        
        final String tipoUnidad = datos['unidad'] ?? 'Desconocido';
        final String numeroSerie = datos['serie'] ?? 'Desconocido';
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            '• $tipoUnidad: $numeroSerie',
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }
}