import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../features/auth/presentation/bloc/marca_bloc.dart';
import 'registrar_material_page.dart';

class MaterialesPage extends StatelessWidget {
  const MaterialesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materiales'),
        actions: [
          // Botón para agregar nuevo material
          ElevatedButton.icon(
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
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Nuevo Material'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF193F6E),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16), // Espacio al final
        ],
      ),
      body: const Center(
        child: Text(
          'Estoy en la página de materiales',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}