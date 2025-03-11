import 'package:flutter/material.dart';
import 'ticket_prestamos_material_page.dart';

class PrestarMaterialPage extends StatefulWidget {
  const PrestarMaterialPage({super.key});

  @override
  State<PrestarMaterialPage> createState() => _PrestarMaterialPageState();
}

class _PrestarMaterialPageState extends State<PrestarMaterialPage> {
  // Contador de elementos en el carrito
  int elementosEnCarrito = 0;
  
  // Lista de materiales disponibles para préstamo (simularemos datos)
  final List<Map<String, dynamic>> materiales = [
    {
      'nombre': 'Dron',
      'descripcion': 'Dron de codrone con 4 aspas',
      'disponibles': 5,
      'seleccionados': 0,
    },
    {
      'nombre': 'Laptop',
      'descripcion': 'Laptop Lenovo ThinkPad con 16GB RAM',
      'disponibles': 10,
      'seleccionados': 0,
    },
    {
      'nombre': 'Proyector',
      'descripcion': 'Proyector EPSON HD con HDMI',
      'disponibles': 3,
      'seleccionados': 0,
    },
  ];

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
        elementosEnCarrito += cantidadSeleccionada;
        // Podríamos guardar qué elementos se agregaron para mostrarlos después
        materiales[index]['seleccionados'] = 0; // Reiniciar contador después de agregar
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
                // Navegar a la página de ticket
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TicketPrestamosMaterialPage(),
                  ),
                );
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
          
          // Lista de materiales disponibles
          Expanded(
            child: ListView.builder(
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
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                // Botón para decrementar
                                ElevatedButton(
                                  onPressed: () => decrementar(index),
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
                                  onPressed: () => incrementar(index),
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
                                  onPressed: () => agregarAlCarrito(index),
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