import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/marca_bloc.dart';

import '../../domain/entities/marca.dart';

class RegistrarMarcaPage extends StatefulWidget {
  const RegistrarMarcaPage({super.key});

  @override
  State<RegistrarMarcaPage> createState() => _RegistrarMarcaPageState();
}

class _RegistrarMarcaPageState extends State<RegistrarMarcaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreMarcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _fabricanteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8FF),
        title: const Text('Registrar Nueva Marca'),
      ),
      body: BlocListener<MarcaBloc, MarcaState>(
        listener: (context, state) {
          if (state is MarcaOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Marca registrada con éxito'),
                backgroundColor: Colors.green,
              ),
            );
            // Limpiar el formulario y volver atrás
            _nombreMarcaController.clear();
            _modeloController.clear();
            _fabricanteController.clear();
            Navigator.pop(context);
          } else if (state is MarcaOperationFailure) {
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
                
                // Nombre de la marca
                TextFormField(
                  controller: _nombreMarcaController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la Marca',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    ),
                    prefixIcon: Icon(Icons.branding_watermark, color: Color(0xFF193F6E)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre de la marca es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Modelo de la marca
                TextFormField(
                  controller: _modeloController,
                  decoration: const InputDecoration(
                    labelText: 'Modelo de la Marca',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    ),
                    prefixIcon: Icon(Icons.model_training, color: Color(0xFF193F6E)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El modelo de la marca es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Fabricante de la marca
                TextFormField(
                  controller: _fabricanteController,
                  decoration: const InputDecoration(
                    labelText: 'Fabricante de la Marca',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    ),
                    prefixIcon: Icon(Icons.factory, color: Color(0xFF193F6E)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El fabricante de la marca es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Botón de registro
                BlocBuilder<MarcaBloc, MarcaState>(
                  builder: (context, state) {
                    return ElevatedButton.icon(
                      onPressed: state is MarcaLoading 
                          ? null 
                          : () {
                              if (_formKey.currentState!.validate()) {
                                final nuevaMarca = Marca(
                                  id: '', // Se generará en Firebase
                                  idMarca: 0, // Se autoincrementará en el repositorio
                                  nombreMarca: _nombreMarcaController.text,
                                  modeloDeLaMarca: _modeloController.text,
                                  fabricanteDeLaMarca: _fabricanteController.text,
                                );
                                
                                context.read<MarcaBloc>().add(AddMarca(nuevaMarca));
                              }
                            },
                      icon: state is MarcaLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ) 
                          : const Icon(Icons.save),
                      label: const Text('Registrar Marca'),
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
    _nombreMarcaController.dispose();
    _modeloController.dispose();
    _fabricanteController.dispose();
    super.dispose();
  }
}