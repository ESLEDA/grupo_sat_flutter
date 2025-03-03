import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/marca_bloc.dart';
import '../../domain/entities/marca.dart';
import 'registrar_marca_page.dart';

class MarcasPage extends StatefulWidget {
  const MarcasPage({super.key});

  @override
  State<MarcasPage> createState() => _MarcasPageState();
}

class _MarcasPageState extends State<MarcasPage> {
  @override
  void initState() {
    super.initState();
    // Cargar las marcas al iniciar la página
    context.read<MarcaBloc>().add(LoadMarcas());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Marcas'),
            SizedBox(height: 4),
            Text(
              'Gestión de marcas registradas',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF5F8FF),
      ),
      body: BlocBuilder<MarcaBloc, MarcaState>(
        builder: (context, state) {
          if (state is MarcaLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MarcasLoaded) {
            final marcas = state.marcas;
            
            return marcas.isEmpty
                ? const Center(
                    child: Text(
                      'No hay marcas registradas',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: marcas.length,
                    itemBuilder: (context, index) {
                      final marca = marcas[index];
                      return MarcaCard(marca: marca);
                    },
                  );
          } else if (state is MarcaOperationFailure) {
            return Center(
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
                    state.message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MarcaBloc>().add(LoadMarcas());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No hay información disponible'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegistrarMarcaPage(),
            ),
          ).then((_) {
            // Recargar las marcas cuando vuelva
            context.read<MarcaBloc>().add(LoadMarcas());
          });
        },
        backgroundColor: const Color(0xFF193F6E),
        icon: const Icon(
          CupertinoIcons.add,
          color: Colors.white,
        ),
        label: const Text(
          'Nueva Marca',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class MarcaCard extends StatelessWidget {
  final Marca marca;

  const MarcaCard({
    super.key,
    required this.marca,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          // Encabezado de la tarjeta con el nombre de la marca
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF193F6E),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.branding_watermark,
                          color: Color(0xFF193F6E),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          marca.nombreMarca,
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
                Text(
                  'ID: ${marca.idMarca}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido de la tarjeta
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modelo
                Row(
                  children: [
                    const Icon(Icons.model_training, 
                      size: 20, 
                      color: Color(0xFF193F6E)
                    ),
                    const SizedBox(width: 8.0),
                    const Text(
                      'Modelo:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        marca.modeloDeLaMarca,
                        style: const TextStyle(fontSize: 14.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                
                // Fabricante
                Row(
                  children: [
                    const Icon(Icons.factory, 
                      size: 20, 
                      color: Color(0xFF193F6E)
                    ),
                    const SizedBox(width: 8.0),
                    const Text(
                      'Fabricante:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        marca.fabricanteDeLaMarca,
                        style: const TextStyle(fontSize: 14.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Botones de acción
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botón de editar
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF193F6E)),
                  onPressed: () {
                    // Aquí podríamos implementar la edición
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edición no implementada aún')),
                    );
                  },
                ),
                // Botón de eliminar
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Mostrar diálogo de confirmación
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Eliminar marca'),
                        content: Text('¿Está seguro de eliminar la marca ${marca.nombreMarca}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Eliminar marca
                              context.read<MarcaBloc>().add(DeleteMarca(marca.id));
                              Navigator.pop(context);
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
  }
}