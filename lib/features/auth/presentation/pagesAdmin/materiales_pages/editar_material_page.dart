import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../features/auth/presentation/bloc/marca_bloc.dart';
import '../../../../../features/auth/domain/entities/marca.dart';
import 'material_serie_item.dart';

class EditarMaterialPage extends StatefulWidget {
  final Map<String, dynamic> material;

  const EditarMaterialPage({super.key, required this.material});

  @override
  State<EditarMaterialPage> createState() => _EditarMaterialPageState();
}

class _EditarMaterialPageState extends State<EditarMaterialPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _cantidadController;
  String? _marcaSeleccionada;
  
  // Lista para manejar los números de serie
  List<MaterialSerieItem> _serieItems = [];
  
  bool _isLoading = false;
  bool _isCargandoMarcas = true;
  String _errorMessage = '';
  List<Marca> _listaMarcas = [];

  @override
  void initState() {
    super.initState();
    // Inicializar controladores con datos existentes
    _nombreController = TextEditingController(text: widget.material['nombreMaterial']);
    _descripcionController = TextEditingController(text: widget.material['descripcionMaterial']);
    _cantidadController = TextEditingController(text: widget.material['cantidadUnidades']?.toString());
    _marcaSeleccionada = widget.material['marcaMaterial'];
    
    // Cargar números de serie existentes
    _cargarSeriesExistentes();
    
    // Cargar las marcas
    _cargarMarcas();
  }
  
  void _cargarMarcas() {
    // Usar el BLoC para cargar las marcas
    context.read<MarcaBloc>().add(LoadMarcas());
  }
  
  void _cargarSeriesExistentes() {
    // Verificar si existen números de serie en el material
    final seriesMap = widget.material['numeroSerie'];
    if (seriesMap != null && seriesMap is Map) {
      int index = 0;
      seriesMap.forEach((key, value) {
        if (value is Map) {
          String serie = value['serie'] ?? '';
          String unidad = value['unidad'] ?? '';
          
          _serieItems.add(
            MaterialSerieItem(
              index: index,
              onRemove: _removerSerieItem,
              numeroSerie: serie,
              unidad: unidad,
            ),
          );
          index++;
        }
      });
    }
    
    // Si no hay series, agregar al menos una por defecto
    if (_serieItems.isEmpty) {
      _serieItems.add(MaterialSerieItem(index: 0, onRemove: _removerSerieItem));
    }
  }
  
  void _agregarSerieItem() {
    setState(() {
      _serieItems.add(
        MaterialSerieItem(
          index: _serieItems.length,
          onRemove: _removerSerieItem,
        ),
      );
    });
  }
  
  void _removerSerieItem(int index) {
    setState(() {
      _serieItems.removeWhere((item) => item.index == index);
      
      // Reajustar los índices
      for (int i = 0; i < _serieItems.length; i++) {
        _serieItems[i] = MaterialSerieItem(
          index: i,
          onRemove: _removerSerieItem,
          numeroSerie: _serieItems[i].getNumeroSerie(),
          unidad: _serieItems[i].getUnidad(),
        );
      }
    });
  }

  Future<void> _actualizarMaterial() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Validación de marca seleccionada
    if (_marcaSeleccionada == null) {
      setState(() {
        _errorMessage = 'Por favor seleccione una marca';
      });
      return;
    }
    
    // Validación adicional: verificar que la cantidad coincida con los números de serie
    int cantidad = int.tryParse(_cantidadController.text) ?? 0;
    if (cantidad != _serieItems.length) {
      setState(() {
        _errorMessage = 'La cantidad debe coincidir con el número de unidades ingresadas';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Crear un mapa con los números de serie
      Map<String, Map<String, String>> numeroSerie = {};
      for (int i = 0; i < _serieItems.length; i++) {
        MaterialSerieItem item = _serieItems[i];
        numeroSerie['unidad_$i'] = {
          'serie': item.getNumeroSerie(),
          'unidad': item.getUnidad(),
        };
      }

      // Actualizar en Firestore
      await FirebaseFirestore.instance.collection('materiales').doc(widget.material['id']).update({
        'nombreMaterial': _nombreController.text,
        'marcaMaterial': _marcaSeleccionada,
        'cantidadUnidades': cantidad,
        'numeroSerie': numeroSerie,
        'descripcionMaterial': _descripcionController.text,
        'fechaActualizacion': Timestamp.now(),
      });

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Material actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Volver a la página anterior con resultado para actualizar la lista
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al actualizar material: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                'Editar Material',
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
              child: BlocListener<MarcaBloc, MarcaState>(
                listener: (context, state) {
                  if (state is MarcasLoaded) {
                    setState(() {
                      _listaMarcas = state.marcas;
                      _isCargandoMarcas = false;
                    });
                  } else if (state is MarcaOperationFailure) {
                    setState(() {
                      _isCargandoMarcas = false;
                      _errorMessage = state.message;
                    });
                  }
                },
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Mensaje de error (si hay)
                      if (_errorMessage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.only(bottom: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red.shade900),
                          ),
                        ),
                      
                      // Nombre del material
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Material',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          prefixIcon: Icon(Icons.inventory, color: Color(0xFF193F6E)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El nombre del material es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Descripción del material
                      TextFormField(
                        controller: _descripcionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción del Material',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          prefixIcon: Icon(Icons.description, color: Color(0xFF193F6E)),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La descripción es requerida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Dropdown para seleccionar marca
                      BlocBuilder<MarcaBloc, MarcaState>(
                        builder: (context, state) {
                          if (state is MarcaLoading || _isCargandoMarcas) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (state is MarcasLoaded || _listaMarcas.isNotEmpty) {
                            // Si no hay marcas, mostrar mensaje
                            if (_listaMarcas.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Text('No hay marcas disponibles.'),
                              );
                            }
                            
                            // Verificar si la marca seleccionada existe en la lista
                            bool marcaExiste = _listaMarcas.any((marca) => marca.nombreMarca == _marcaSeleccionada);
                            if (!marcaExiste) {
                              _marcaSeleccionada = null; // Resetear si no existe
                            }
                            
                            // Dropdown con las marcas disponibles
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.label, color: Color(0xFF193F6E)),
                                  ),
                                  hint: const Text('Seleccionar Marca'),
                                  value: _marcaSeleccionada,
                                  items: _listaMarcas.map((marca) {
                                    return DropdownMenuItem<String>(
                                      value: marca.nombreMarca,
                                      child: Text(marca.nombreMarca),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _marcaSeleccionada = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor seleccione una marca';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            );
                          } else {
                            // Si hay un error o no se pudo cargar las marcas, mostrar un mensaje
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Text('Error al cargar las marcas. Intente nuevamente.'),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Cantidad de unidades
                      TextFormField(
                        controller: _cantidadController,
                        decoration: const InputDecoration(
                          labelText: 'Cantidad de Unidades',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          prefixIcon: Icon(Icons.numbers, color: Color(0xFF193F6E)),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La cantidad es requerida';
                          }
                          if (int.tryParse(value) == null || int.parse(value) <= 0) {
                            return 'La cantidad debe ser un número positivo';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          // Actualizar la cantidad de elementos de serie
                          int newCantidad = int.tryParse(value) ?? 0;
                          if (newCantidad > 0) {
                            setState(() {
                              // Ajustar la lista de ítems según la nueva cantidad
                              if (newCantidad > _serieItems.length) {
                                // Agregar nuevos ítems
                                for (int i = _serieItems.length; i < newCantidad; i++) {
                                  _serieItems.add(
                                    MaterialSerieItem(
                                      index: i,
                                      onRemove: _removerSerieItem,
                                    ),
                                  );
                                }
                              } else if (newCantidad < _serieItems.length) {
                                // Eliminar ítems sobrantes
                                _serieItems.removeRange(newCantidad, _serieItems.length);
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Sección de Números de Serie
                      const Text(
                        'Números de Serie',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Lista de campos para números de serie
                      ..._serieItems,
                      
                      // Botón para agregar más números de serie
                      OutlinedButton.icon(
                        onPressed: _agregarSerieItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar Número de Serie'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF193F6E),
                          side: const BorderSide(color: Color(0xFF193F6E)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Botón de actualización
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _actualizarMaterial,
                        icon: _isLoading 
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }
}