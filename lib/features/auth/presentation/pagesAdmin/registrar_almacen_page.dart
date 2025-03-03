import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/almacen_bloc.dart';

import '../../domain/entities/almacen.dart';

class RegistrarAlmacenPage extends StatefulWidget {
  const RegistrarAlmacenPage({super.key});

  @override
  State<RegistrarAlmacenPage> createState() => _RegistrarAlmacenPageState();
}

class _RegistrarAlmacenPageState extends State<RegistrarAlmacenPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreAlmacenController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8FF),
        title: const Text('Registrar Nuevo Almacén'),
      ),
      body: BlocListener<AlmacenBloc, AlmacenState>(
        listener: (context, state) {
          if (state is AlmacenOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Almacén registrado con éxito'),
                backgroundColor: Colors.green,
              ),
            );
            // Limpiar el formulario y volver atrás
            _nombreAlmacenController.clear();
            Navigator.pop(context);
          } else if (state is AlmacenOperationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo o imagen ilustrativa
                Center(
                  child: Image.asset(
                    'assets/images/Logo-SAT.png',
                    height: 100,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Nombre del almacén
                TextFormField(
                  controller: _nombreAlmacenController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Almacén',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    ),
                    prefixIcon: Icon(Icons.warehouse, color: Color(0xFF193F6E)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre del almacén es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Botón de registro
                BlocBuilder<AlmacenBloc, AlmacenState>(
                  builder: (context, state) {
                    return ElevatedButton.icon(
                      onPressed: state is AlmacenLoading 
                          ? null 
                          : () {
                              if (_formKey.currentState!.validate()) {
                                final nuevoAlmacen = Almacen(
                                  id: '', // Se generará en Firebase
                                  idAlmacen: 0, // Se autoincrementará en el repositorio
                                  nombreAlmacen: _nombreAlmacenController.text,
                                );
                                
                                context.read<AlmacenBloc>().add(AddAlmacen(nuevoAlmacen));
                              }
                            },
                      icon: state is AlmacenLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ) 
                          : const Icon(Icons.save),
                      label: const Text('Registrar Almacén'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF193F6E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreAlmacenController.dispose();
    super.dispose();
  }
}