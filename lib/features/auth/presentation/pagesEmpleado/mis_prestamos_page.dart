import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'entregar_mi_prestamo_page.dart';

class MisPrestamosPage extends StatefulWidget {
  const MisPrestamosPage({super.key});

  @override
  State<MisPrestamosPage> createState() => _MisPrestamosPageState();
}

class _MisPrestamosPageState extends State<MisPrestamosPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Map<String, dynamic>> _prestamos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarPrestamos();
  }

  Future<void> _cargarPrestamos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String empleadoId = _auth.currentUser?.uid ?? '';
      if (empleadoId.isEmpty) {
        setState(() {
          _errorMessage = 'No se pudo identificar al empleado actual';
          _isLoading = false;
        });
        return;
      }

      final snapshot = await _firestore
          .collection('prestamos')
          .where('encargadoEmpleado', isEqualTo: empleadoId)
          .where('estado', isEqualTo: 'prestado')
          .orderBy('fechaRegistro', descending: true)
          .get();

      List<Map<String, dynamic>> listaTemp = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Obtener lista de materiales prestados
        Map<String, dynamic> materialesPrestados = data['listaMaterialesPrestados'] ?? {};
        List<Map<String, dynamic>> listaMateriales = [];
        
        materialesPrestados.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            listaMateriales.add({
              'id': value['id'] ?? '',
              'nombre': value['nombre'] ?? 'Sin nombre',
              'descripcion': value['descripcion'] ?? 'Sin descripción',
              'cantidad': value['cantidad'] ?? 0,
              'almacen': value['almacen'] ?? 'Sin almacén',
              'marcaMaterial': value['marcaMaterial'] ?? 'Sin marca',
              'numeroSerie': value['numeroSerie'] ?? {},
            });
          }
        });
        
        listaTemp.add({
          'id': doc.id,
          'fechaDelPrestamo': data['fechaDelPrestamo'] ?? '',
          'fechaDeEntrega': data['fechaDeEntrega'] ?? '',
          'AlmacenDeSalida': data['AlmacenDeSalida'] ?? '',
          'encargadoAdministrador': data['encargadoAdministrador'] ?? '',
          'idAdministrador': data['idAdministrador'] ?? '',
          'materiales': listaMateriales,
          'fechaRegistro': data['fechaRegistro'],
          'estado': data['estado'] ?? '',
        });
      }
      
      setState(() {
        _prestamos = listaTemp;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los préstamos: $e';
        _isLoading = false;
      });
      print('Error al cargar préstamos: $e');
    }
  }

  // Formateador para mostrar cantidades
  String _formatCantidad(int cantidad, String nombre) {
    if (nombre.toLowerCase().endsWith('s')) {
      return '$cantidad $nombre';
    } else {
      return cantidad > 1 ? '$cantidad ${nombre}s' : '$cantidad $nombre';
    }
  }

  // Verificar si un préstamo está vencido
  bool _estaVencido(String fechaEntrega) {
    try {
      final formato = DateFormat('dd-MM-yyyy');
      final fechaEntregaDate = formato.parse(fechaEntrega);
      final hoy = DateTime.now();
      return fechaEntregaDate.isBefore(DateTime(hoy.year, hoy.month, hoy.day));
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text('Mis Préstamos'),
        backgroundColor: const Color(0xFFF5F8FF),
        actions: [
          // Botón para recargar la lista
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarPrestamos,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _prestamos.isEmpty
                  ? const Center(
                      child: Text(
                        'No tienes préstamos activos',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _prestamos.length,
                      itemBuilder: (context, index) {
                        final prestamo = _prestamos[index];
                        final bool vencido = _estaVencido(prestamo['fechaDeEntrega']);
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              // Encabezado con fechas y estado
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                color: vencido ? Colors.red : const Color(0xFF193F6E),
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Primera fila con nombre del almacén
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Almacén: ${prestamo['AlmacenDeSalida']}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.0,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (vencido)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                              vertical: 4.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            child: const Text(
                                              '¡VENCIDO!',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12.0,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8.0),
                                    
                                    // Segunda fila con fechas (una debajo de otra)
                                    Row(
                                      children: [
                                        // Columna de fecha de préstamo
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Préstamo:',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 2.0),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.calendar_today,
                                                    color: Colors.white,
                                                    size: 14.0,
                                                  ),
                                                  const SizedBox(width: 4.0),
                                                  Text(
                                                    prestamo['fechaDelPrestamo'],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        // Columna de fecha de entrega
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Entrega:',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 2.0),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.calendar_today,
                                                    color: Colors.white,
                                                    size: 14.0,
                                                  ),
                                                  const SizedBox(width: 4.0),
                                                  Text(
                                                    prestamo['fechaDeEntrega'],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Lista de materiales
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Materiales:',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    ...prestamo['materiales'].map<Widget>((material) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                material['nombre'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _formatCantidad(
                                                material['cantidad'],
                                                material['nombre'],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    
                                    const SizedBox(height: 16.0),
                                    
                                    // Botón para entregar material
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EntregarMiPrestamoPage(
                                                prestamoId: prestamo['id'],
                                                prestamoData: prestamo,
                                              ),
                                            ),
                                          ).then((result) {
                                            if (result == true) {
                                              _cargarPrestamos();
                                            }
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF193F6E),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        child: const Text(
                                          'Entregar Material',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}