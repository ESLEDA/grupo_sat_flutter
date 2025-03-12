import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TicketPrestamosMaterialPage extends StatefulWidget {
  final List<Map<String, dynamic>> materialesEnCarrito;

  const TicketPrestamosMaterialPage({
    super.key, 
    required this.materialesEnCarrito,
  });

  @override
  State<TicketPrestamosMaterialPage> createState() => _TicketPrestamosMaterialPageState();
}

class _TicketPrestamosMaterialPageState extends State<TicketPrestamosMaterialPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  DateTime? _fechaPrestamo;
  DateTime? _fechaEntrega;
  String? _administradorSeleccionado;
  String? _idAdministradorSeleccionado;
  
  List<Map<String, dynamic>> _administradores = [];
  List<Map<String, dynamic>> _materiales = [];
  
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fechaPrestamo = DateTime.now();
    _materiales = List.from(widget.materialesEnCarrito);
    // Cargar administradores después de que el widget esté montado completamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarAdministradores();
    });
  }

  Future<void> _cargarAdministradores() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final snapshot = await _firestore.collection('administradores').get();
      List<Map<String, dynamic>> listaTemp = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final nombre = data['nombreAdm'] ?? '';
        final primerApellido = data['primerApellidoAdm'] ?? '';
        final segundoApellido = data['segundoApellidoAdm'] ?? '';
        
        final nombreCompleto = segundoApellido != null && segundoApellido.isNotEmpty
            ? '$nombre $primerApellido $segundoApellido'
            : '$nombre $primerApellido';
            
        listaTemp.add({
          'id': doc.id,
          'nombre': nombreCompleto,
        });
      }
      
      if (mounted) {
        setState(() {
          _administradores = listaTemp;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar administradores: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar los administradores: $e';
          _isLoading = false;
        });
      }
    }
  }

  // Seleccionar fecha de préstamo - Método asíncrono simplificado
  Future<void> _seleccionarFechaPrestamo(BuildContext context) async {
    try {
      final DateTime ahora = DateTime.now();
      final DateTime? fechaSeleccionada = await showDatePicker(
        context: context,
        initialDate: _fechaPrestamo ?? ahora,
        firstDate: ahora,
        lastDate: DateTime(ahora.year + 1, ahora.month, ahora.day),
        // No usar locale para evitar problemas si no está configurado
      );
      
      if (fechaSeleccionada != null && mounted) {
        setState(() {
          _fechaPrestamo = fechaSeleccionada;
          // Resetear fecha entrega si es menor que la nueva fecha de préstamo
          if (_fechaEntrega != null && _fechaEntrega!.isBefore(_fechaPrestamo!.add(const Duration(days: 1)))) {
            _fechaEntrega = null;
          }
        });
      }
    } catch (e) {
      print('Error al seleccionar fecha de préstamo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar fecha: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Seleccionar fecha de entrega - Método asíncrono simplificado
  Future<void> _seleccionarFechaEntrega(BuildContext context) async {
    try {
      if (_fechaPrestamo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, seleccione primero la fecha de préstamo'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      final DateTime fechaMinima = _fechaPrestamo!.add(const Duration(days: 1));
      final DateTime? fechaSeleccionada = await showDatePicker(
        context: context,
        initialDate: _fechaEntrega ?? fechaMinima,
        firstDate: fechaMinima,
        lastDate: DateTime(_fechaPrestamo!.year + 1, _fechaPrestamo!.month, _fechaPrestamo!.day),
        // No usar locale para evitar problemas si no está configurado
      );
      
      if (fechaSeleccionada != null && mounted) {
        setState(() {
          _fechaEntrega = fechaSeleccionada;
        });
      }
    } catch (e) {
      print('Error al seleccionar fecha de entrega: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar fecha: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Eliminar material del carrito
  void _eliminarMaterial(int index) {
    if (index >= 0 && index < _materiales.length) {
      setState(() {
        _materiales.removeAt(index);
      });
    }
  }

  // Realizar el préstamo
  Future<void> _realizarPrestamo() async {
    // Validaciones
    if (_fechaPrestamo == null) {
      setState(() {
        _errorMessage = 'Por favor, seleccione la fecha de préstamo';
      });
      return;
    }
    
    if (_fechaEntrega == null) {
      setState(() {
        _errorMessage = 'Por favor, seleccione la fecha de entrega';
      });
      return;
    }
    
    if (_administradorSeleccionado == null || _idAdministradorSeleccionado == null) {
      setState(() {
        _errorMessage = 'Por favor, seleccione un administrador encargado';
      });
      return;
    }
    
    if (_materiales.isEmpty) {
      setState(() {
        _errorMessage = 'No hay materiales en el carrito';
      });
      return;
    }
    
    // Evitar presionar el botón múltiples veces
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Obtener el ID del empleado actual
      final String empleadoId = _auth.currentUser?.uid ?? '';
      if (empleadoId.isEmpty) {
        throw Exception('No se pudo identificar al empleado actual');
      }
      
      // Formatear fechas
      String fechaPrestamoStr = DateFormat('dd-MM-yyyy').format(_fechaPrestamo!);
      String fechaEntregaStr = DateFormat('dd-MM-yyyy').format(_fechaEntrega!);
      
      // Preparar mapa de materiales prestados
      Map<String, Map<String, dynamic>> listaMaterialesPrestados = {};
      
      // Primero crear la transacción de préstamo
      DocumentReference prestamoRef = await _firestore.collection('prestamos').add({
        'fechaDelPrestamo': fechaPrestamoStr,
        'fechaDeEntrega': fechaEntregaStr,
        'AlmacenDeSalida': _materiales[0]['almacen'], // Tomamos el almacén del primer material
        'encargadoAdministrador': _administradorSeleccionado,
        'idAdministrador': _idAdministradorSeleccionado,
        'encargadoEmpleado': empleadoId,
        'listaMaterialesPrestados': {}, // Inicialmente vacío
        'fechaRegistro': Timestamp.now(),
        'estado': 'prestado', // Para poder filtrar después
      });
      
      // Luego actualizar los materiales uno por uno
      for (int i = 0; i < _materiales.length; i++) {
        final material = _materiales[i];
        listaMaterialesPrestados['material_$i'] = {
          'id': material['id'],
          'nombre': material['nombre'],
          'descripcion': material['descripcion'],
          'cantidad': material['cantidad'],
          'almacen': material['almacen'],
          'marcaMaterial': material['marcaMaterial'],
          'numeroSerie': material['numeroSerie'],
        };
        
        // Actualizar cantidad disponible en la colección de materiales
        await _firestore.collection('materiales').doc(material['id']).update({
          'cantidadUnidades': FieldValue.increment(-material['cantidad']),
        });
      }
      
      // Actualizar el préstamo con la lista completa de materiales
      await prestamoRef.update({
        'listaMaterialesPrestados': listaMaterialesPrestados,
      });
      
      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Préstamo realizado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Volver a la página anterior con indicación de éxito
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error al realizar préstamo: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al realizar el préstamo: $e';
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text('Ticket de Préstamo'),
        backgroundColor: const Color(0xFFF5F8FF),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isProcessing
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Procesando préstamo...'),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF193F6E),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Text(
                          'Carro de préstamos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 16.0),
                      
                      // Mensaje de error si existe
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
                      
                      // Fecha de préstamo
                      ElevatedButton(
                        onPressed: () => _seleccionarFechaPrestamo(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF193F6E),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: const BorderSide(
                              color: Color(0xFF193F6E),
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Fecha de préstamo',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  _fechaPrestamo != null
                                      ? DateFormat('dd-MM-yyyy').format(_fechaPrestamo!)
                                      : 'Seleccionar',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                const Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF193F6E),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16.0),
                      
                      // Fecha de entrega
                      ElevatedButton(
                        onPressed: () => _seleccionarFechaEntrega(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF193F6E),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: const BorderSide(
                              color: Color(0xFF193F6E),
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Fecha de entrega',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  _fechaEntrega != null
                                      ? DateFormat('dd-MM-yyyy').format(_fechaEntrega!)
                                      : 'Seleccionar',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                const Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF193F6E),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16.0),
                      
                      // Dropdown para seleccionar administrador
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                            hint: const Text('Selecciona un administrador'),
                            value: _administradorSeleccionado,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF193F6E),
                            ),
                            items: _administradores.map((admin) {
                              return DropdownMenuItem<String>(
                                value: admin['nombre'],
                                onTap: () {
                                  setState(() {
                                    _idAdministradorSeleccionado = admin['id'];
                                  });
                                },
                                child: Text(admin['nombre']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _administradorSeleccionado = value;
                              });
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24.0),
                      
                      // Resumen del préstamo
                      if (_materiales.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: const Color(0xFF193F6E),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Resumen del préstamo',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16.0),
                              // Lista de materiales en el carrito
                              ...List.generate(_materiales.length, (index) {
                                final material = _materiales[index];
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            material['nombre'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Text('${material['cantidad']}'),
                                      ],
                                    ),
                                    const SizedBox(height: 4.0),
                                    if (index < _materiales.length - 1)
                                      const Divider(),
                                  ],
                                );
                              }),
                              const Divider(thickness: 1.5),
                              const SizedBox(height: 8.0),
                              // Fecha del préstamo (en el resumen)
                              Row(
                                children: [
                                  const Text(
                                    'Fecha del préstamo:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _fechaPrestamo != null
                                        ? DateFormat('dd-MM-yyyy').format(_fechaPrestamo!)
                                        : '-',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                              
                              // Botón para realizar préstamo
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isProcessing ? null : _realizarPrestamo,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD7282F),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  child: const Text(
                                    'Realizar préstamo',
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
                      
                      const SizedBox(height: 24.0),
                      
                      // Lista de materiales en el carrito (cards)
                      ..._materiales.asMap().entries.map((entry) {
                        int index = entry.key;
                        var material = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Column(
                            children: [
                              // Encabezado con nombre y descripción
                              Container(
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
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        material['nombre'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        material['descripcion'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Parte inferior con cantidad y botón para eliminar
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'En carrito: ${material['cantidad']}',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => _eliminarMaterial(index),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFD7282F),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 12.0,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
    );
  }
}