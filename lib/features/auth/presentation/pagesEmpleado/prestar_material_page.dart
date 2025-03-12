import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ticket_prestamos_material_page.dart';

class PrestarMaterialPage extends StatefulWidget {
  const PrestarMaterialPage({super.key});

  @override
  State<PrestarMaterialPage> createState() => _PrestarMaterialPageState();
}

class _PrestarMaterialPageState extends State<PrestarMaterialPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Contador de elementos en el carrito
  int elementosEnCarrito = 0;
  
  // Material seleccionado para el carrito
  List<Map<String, dynamic>> materialesEnCarrito = [];
  
  // Lista de almacenes disponibles
  List<String> almacenes = [];
  String? almacenSeleccionado;
  
  // Lista de materiales disponibles para préstamo
  List<Map<String, dynamic>> materiales = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarAlmacenes();
    _cargarMateriales();
  }

  // Método para cargar los almacenes desde Firebase
  Future<void> _cargarAlmacenes() async {
    try {
      final snapshot = await _firestore.collection('almacenes').get();
      List<String> listaTemporal = [];
      
      for (var doc in snapshot.docs) {
        listaTemporal.add(doc.data()['nombreAlmacen'] ?? '');
      }
      
      setState(() {
        almacenes = listaTemporal;
      });
    } catch (e) {
      print('Error al cargar los almacenes: $e');
    }
  }

  // Método para cargar los materiales desde Firebase
  Future<void> _cargarMateriales() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      QuerySnapshot snapshot;
      
      // Aplicar filtro de almacén si hay uno seleccionado
      if (almacenSeleccionado != null) {
        snapshot = await _firestore
            .collection('materiales')
            .where('almacen', isEqualTo: almacenSeleccionado)
            .get();
      } else {
        snapshot = await _firestore.collection('materiales').get();
      }
      
      List<Map<String, dynamic>> listaTemporal = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        listaTemporal.add({
          'id': doc.id,
          'nombre': data['nombreMaterial'] ?? 'Sin nombre',
          'descripcion': data['descripcionMaterial'] ?? 'Sin descripción',
          'disponibles': data['cantidadUnidades'] ?? 0,
          'seleccionados': 0,
          'almacen': data['almacen'] ?? 'Sin almacén',
          'marcaMaterial': data['marcaMaterial'] ?? 'Sin marca',
          'numeroSerie': data['numeroSerie'] ?? {},
        });
      }
      
      setState(() {
        materiales = listaTemporal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los materiales: $e';
        _isLoading = false;
      });
      print('Error al cargar los materiales: $e');
    }
  }

  // Método para incrementar la cantidad seleccionada
  void incrementar(int index) {
    setState(() {
      if (materiales[index]['seleccionados'] < materiales[index]['disponibles']) {
        materiales[index]['seleccionados']++;
      }
    });
  }

  // Método para decrementar la cantidad seleccionada
  void decrementar(int index) {
    setState(() {
      if (materiales[index]['seleccionados'] > 0) {
        materiales[index]['seleccionados']--;
      }
    });
  }

  // Método para agregar al carrito
  void agregarAlCarrito(int index) {
    final int cantidadSeleccionada = materiales[index]['seleccionados'] as int;
    if (cantidadSeleccionada > 0) {
      setState(() {
        // Actualizar disponibles restando los seleccionados
        materiales[index]['disponibles'] -= cantidadSeleccionada;
        
        // Agregar al carrito
        materialesEnCarrito.add({
          'id': materiales[index]['id'],
          'nombre': materiales[index]['nombre'],
          'descripcion': materiales[index]['descripcion'],
          'cantidad': cantidadSeleccionada,
          'almacen': materiales[index]['almacen'],
          'marcaMaterial': materiales[index]['marcaMaterial'],
          'numeroSerie': materiales[index]['numeroSerie'],
        });
        
        elementosEnCarrito += cantidadSeleccionada;
        
        // Reiniciar contador de seleccionados
        materiales[index]['seleccionados'] = 0;
      });

      // Mostrar mensaje de confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Se agregaron $cantidadSeleccionada ${materiales[index]['nombre']} al carrito'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text('Préstamo de Material'),
        backgroundColor: const Color(0xFFF5F8FF),
      ),
      body: Column(
        children: [
          // Botón de carrito de préstamos
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                if (elementosEnCarrito > 0) {
                  // Navegar a la página de ticket con los materiales seleccionados
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicketPrestamosMaterialPage(
                        materialesEnCarrito: materialesEnCarrito,
                      ),
                    ),
                  ).then((result) {
                    // Si regresamos del ticket, actualizamos los materiales
                    if (result == true) {
                      setState(() {
                        elementosEnCarrito = 0;
                        materialesEnCarrito = [];
                      });
                      _cargarMateriales();
                    }
                  });
                } else {
                  // Mostrar mensaje si el carrito está vacío
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El carrito está vacío'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF193F6E),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'carro de préstamos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        if (elementosEnCarrito > 0)
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$elementosEnCarrito',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Selector de almacén
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50.0),
                border: Border.all(color: const Color(0xFF193F6E)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  value: almacenSeleccionado,
                  hint: const Text('Seleccionar almacén'),
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF193F6E)),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Todos los almacenes'),
                    ),
                    ...almacenes.map((almacen) {
                      return DropdownMenuItem<String?>(
                        value: almacen,
                        child: Text(almacen),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      almacenSeleccionado = value;
                    });
                    _cargarMateriales(); // Recargar materiales con filtro
                  },
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Lista de materiales disponibles
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : materiales.isEmpty
                        ? Center(
                            child: Text(
                              almacenSeleccionado != null
                                  ? 'No hay materiales disponibles en el almacén $almacenSeleccionado'
                                  : 'No hay materiales disponibles',
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: materiales.length,
                            itemBuilder: (context, index) {
                              final material = materiales[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  children: [
                                    // Encabezado con nombre y descripción
                                    Container(
                                      padding: const EdgeInsets.all(16.0),
                                      color: const Color(0xFF193F6E),
                                      width: double.infinity,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              material['nombre'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.0,
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
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Parte inferior con cantidad y botones
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Disponibles: ${material['disponibles']}',
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                            ),
                                          ),
                                          Text(
                                            'Almacén: ${material['almacen']}',
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              // Botón para decrementar
                                              ElevatedButton(
                                                onPressed: material['disponibles'] > 0 
                                                    ? () => decrementar(index)
                                                    : null,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(12),
                                                      bottomLeft: Radius.circular(12),
                                                    ),
                                                  ),
                                                  minimumSize: const Size(60, 50),
                                                ),
                                                child: const Icon(Icons.remove, color: Colors.white),
                                              ),
                                              
                                              // Contador
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                child: Text(
                                                  '${material['seleccionados']}',
                                                  style: const TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              
                                              // Botón para incrementar
                                              ElevatedButton(
                                                onPressed: material['disponibles'] > 0 
                                                    ? () => incrementar(index)
                                                    : null,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.only(
                                                      topRight: Radius.circular(12),
                                                      bottomRight: Radius.circular(12),
                                                    ),
                                                  ),
                                                  minimumSize: const Size(60, 50),
                                                ),
                                                child: const Icon(Icons.add, color: Colors.white),
                                              ),
                                              
                                              const Spacer(),
                                              
                                              // Botón "Agregar" para añadir al carrito
                                              ElevatedButton(
                                                onPressed: material['disponibles'] > 0 && material['seleccionados'] > 0
                                                    ? () => agregarAlCarrito(index)
                                                    : null,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                ),
                                                child: const Text(
                                                  'Agregar',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}