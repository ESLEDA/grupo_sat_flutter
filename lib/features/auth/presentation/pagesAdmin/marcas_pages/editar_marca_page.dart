import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/marca_bloc.dart';
import '../../../domain/entities/marca.dart';

class EditarMarcaPage extends StatefulWidget {
  final Marca marca;

  const EditarMarcaPage({super.key, required this.marca});

  @override
  State<EditarMarcaPage> createState() => _EditarMarcaPageState();
}

class _EditarMarcaPageState extends State<EditarMarcaPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreMarcaController;
  late TextEditingController _modeloController;
  late TextEditingController _fabricanteController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nombreMarcaController = TextEditingController(text: widget.marca.nombreMarca);
    _modeloController = TextEditingController(text: widget.marca.modeloDeLaMarca);
    _fabricanteController = TextEditingController(text: widget.marca.fabricanteDeLaMarca);
  }

  @override
  void dispose() {
    _nombreMarcaController.dispose();
    _modeloController.dispose();
    _fabricanteController.dispose();
    super.dispose();
  }

  void _guardarCambios() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      
      final marcaActualizada = Marca(
        id: widget.marca.id,
        idMarca: widget.marca.idMarca,
        nombreMarca: _nombreMarcaController.text,
        modeloDeLaMarca: _modeloController.text,
        fabricanteDeLaMarca: _fabricanteController.text,
      );
      
      context.read<MarcaBloc>().add(UpdateMarca(marcaActualizada));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marca actualizada con éxito'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context, marcaActualizada);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFF5F8FF),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'Editar Marca',
                style: TextStyle(
                  color: Color(0xFF444957),
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              background: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Logo-SAT.png',
                      height: 62,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                    
                    // Modelo
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
                          return 'El modelo es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Fabricante
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
                          return 'El fabricante es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Botón de guardar
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _guardarCambios,
                      icon: _isSaving 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ) 
                          : const Icon(Icons.save),
                      label: const Text('Guardar Cambios'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF193F6E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}