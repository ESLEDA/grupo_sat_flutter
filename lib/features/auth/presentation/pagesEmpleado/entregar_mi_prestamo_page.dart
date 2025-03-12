import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EntregarMiPrestamoPage extends StatefulWidget {
  final String prestamoId;
  final Map<String, dynamic> prestamoData;

  const EntregarMiPrestamoPage({
    super.key,
    required this.prestamoId,
    required this.prestamoData,
  });

  @override
  State<EntregarMiPrestamoPage> createState() => _EntregarMiPrestamoPageState();
}

class _EntregarMiPrestamoPageState extends State<EntregarMiPrestamoPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<String> _almacenes = [];
  String? _almacenSeleccionado;
  String _almacenOriginal = '';
  bool _isLoading = true;
  bool _processingReturn = false;
  String? _errorMessage;
  
  final TextEditingController _observacionesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _almacenOriginal = widget.prestamoData['AlmacenDeSalida'];
    _cargarAlmacenes();
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  // Método para cargar los almacenes desde Firebase
  Future<void> _cargarAlmacenes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final snapshot = await _firestore.collection('almacenes').get();
      List<String> listaTemporal = [];
      
      for (var doc in snapshot.docs) {
        listaTemporal.add(doc.data()['nombreAlmacen'] ?? '');
      }
      
      setState(() {
        _almacenes = listaTemporal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los almacenes: $e';
        _isLoading = false;
      });
      print('Error al cargar los almacenes: $e');
    }
  }

  // Método para realizar la entrega del material
  Future<void> _entregarMaterial() async {
    if (_almacenSeleccionado == null) {
      setState(() {
        _errorMessage = 'Por favor, selecciona un almacén para la entrega';
      });
      return;
    }

    setState(() {
      _processingReturn = true;
      _errorMessage = null;
    });

    try {
      // Obtener todos los materiales del préstamo
      List<Map<String, dynamic>> materialesPrestamo = List<Map<String, dynamic>>.from(widget.prestamoData['materiales']);
      
      // Procesar cada material
      for (var material in materialesPrestamo) {
        final String materialId = material['id'];
        final int cantidad = material['cantidad'];
        
        if (_almacenSeleccionado == _almacenOriginal) {
          // Si el almacén es el mismo, simplemente actualizar el stock
          await _firestore.collection('materiales').doc(materialId).update({
            'cantidadUnidades': FieldValue.increment(cantidad),
          });
        } else {
          // Si el almacén es diferente, verificar si ya existe el material en ese almacén
          QuerySnapshot existingMatQuery = await _firestore
              .collection('materiales')
              .where('nombreMaterial', isEqualTo: material['nombre'])
              .where('almacen', isEqualTo: _almacenSeleccionado)
              .limit(1)
              .get();
          
          if (existingMatQuery.docs.isNotEmpty) {
            // Si existe, actualizar la cantidad
            await _firestore.collection('materiales').doc(existingMatQuery.docs.first.id).update({
              'cantidadUnidades': FieldValue.increment(cantidad),
            });
          } else {
            // Si no existe, crear un nuevo material
            await _firestore.collection('materiales').add({
              'nombreMaterial': material['nombre'],
              'descripcionMaterial': material['descripcion'],
              'cantidadUnidades': cantidad,
              'almacen': _almacenSeleccionado,
              'marcaMaterial': material['marcaMaterial'],
              'numeroSerie': material['numeroSerie'],
            });
          }
        }
      }
      
      // Actualizar el estado del préstamo a "entregado"
      await _firestore.collection('prestamos').doc(widget.prestamoId).update({
        'estado': 'entregado',
        'fechaDeEntregaReal': DateFormat('dd-MM-yyyy').format(DateTime.now()),
        'almacenDeEntrega': _almacenSeleccionado,
        'observaciones': _observacionesController.text.trim(),
      });
      
      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Material entregado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Volver a la página anterior con indicación de éxito
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al entregar el material: $e';
        _processingReturn = false;
      });
      print('Error al entregar material: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text('Entregar Material'),
        backgroundColor: const Color(0xFFF5F8FF),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _processingReturn
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Procesando entrega...'),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título de la página
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF193F6E),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Text(
                          'Entregar Material',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 16.0),
                      
                      // Mostrar error si existe
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.only(bottom: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.red.shade300),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade800),
                          ),
                        ),
                      
                      // Información del préstamo
                      Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Detalles del préstamo',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16.0),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    'Fecha de préstamo: ${widget.prestamoData['fechaDelPrestamo']}',
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16.0),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    'Fecha de entrega: ${widget.prestamoData['fechaDeEntrega']}',
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  const Icon(Icons.store, size: 16.0),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    'Almacén de salida: $_almacenOriginal',
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 16.0),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    'Administrador: ${widget.prestamoData['encargadoAdministrador']}',
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Lista de materiales
                      Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Materiales a entregar',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              ...widget.prestamoData['materiales'].map<Widget>((material) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          material['nombre'],
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '${material['cantidad']} unidades',
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                      
                      // Selector de almacén
                      Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Seleccionar almacén de entrega',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: const Color(0xFF193F6E),
                                    width: 1.0,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    hint: const Text('Seleccionar almacén'),
                                    value: _almacenSeleccionado,
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Color(0xFF193F6E),
                                    ),
                                    items: _almacenes.map((almacen) {
                                      return DropdownMenuItem<String>(
                                        value: almacen,
                                        child: Text(
                                          almacen,
                                          style: TextStyle(
                                            fontWeight: almacen == _almacenOriginal
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: almacen == _almacenOriginal
                                                ? const Color(0xFF193F6E)
                                                : Colors.black,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _almacenSeleccionado = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              if (_almacenSeleccionado != null && _almacenSeleccionado != _almacenOriginal)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Nota: Los materiales serán registrados en el almacén $_almacenSeleccionado',
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.blue,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Campo de observaciones
                      Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Observaciones',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              TextField(
                                controller: _observacionesController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'Ingrese cualquier observación sobre la entrega del material',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF193F6E),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF193F6E),
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Botón para confirmar entrega
                      SizedBox(
                        height: 50.0,
                        child: ElevatedButton(
                          onPressed: _entregarMaterial,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF193F6E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: const Text(
                            'CONFIRMAR ENTREGA',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}