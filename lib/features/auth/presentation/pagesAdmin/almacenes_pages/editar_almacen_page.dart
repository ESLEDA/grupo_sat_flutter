import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/almacen_bloc.dart';
import '../../../domain/entities/almacen.dart';

class EditarAlmacenPage extends StatefulWidget {
  final Almacen almacen;

  const EditarAlmacenPage({super.key, required this.almacen});

  @override
  State<EditarAlmacenPage> createState() => _EditarAlmacenPageState();
}

class _EditarAlmacenPageState extends State<EditarAlmacenPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreAlmacenController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nombreAlmacenController = TextEditingController(text: widget.almacen.nombreAlmacen);
  }

  @override
  void dispose() {
    _nombreAlmacenController.dispose();
    super.dispose();
  }

  void _guardarCambios() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      
      final almacenActualizado = Almacen(
        id: widget.almacen.id,
        idAlmacen: widget.almacen.idAlmacen,
        nombreAlmacen: _nombreAlmacenController.text,
      );
      
      context.read<AlmacenBloc>().add(UpdateAlmacen(almacenActualizado));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Almacén actualizado con éxito'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context, almacenActualizado);
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
                'Editar Almacén',
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