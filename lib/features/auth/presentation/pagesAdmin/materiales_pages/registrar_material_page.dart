import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'material_serie_item.dart';

class RegistrarMaterialPage extends StatefulWidget {
  const RegistrarMaterialPage({super.key});

  @override
  State<RegistrarMaterialPage> createState() => _RegistrarMaterialPageState();
}

class _RegistrarMaterialPageState extends State<RegistrarMaterialPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _marcaController = TextEditingController();
  final _cantidadController = TextEditingController();
  
  // Lista para manejar los números de serie
  final List<MaterialSerieItem> _serieItems = [];
  
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Inicialmente agregamos un item para que el usuario pueda agregar al menos un número de serie
    _serieItems.add(MaterialSerieItem(index: 0, onRemove: _removerSerieItem));
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

  Future<void> _registrarMaterial() async {
    if (!_formKey.currentState!.validate()) {
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

      // Guardar en Firestore
      await FirebaseFirestore.instance.collection('materiales').add({
        'nombreMaterial': _nombreController.text,
        'marcaMaterial': _marcaController.text,
        'cantidadUnidades': cantidad,
        'numeroSerie': numeroSerie,
        'fechaRegistro': Timestamp.now(),
      });

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Material registrado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Volver a la página anterior
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al registrar material: $e';
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
      appBar: AppBar(
        title: const Text('Registrar Material'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre del material';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Marca del material
              TextFormField(
                controller: _marcaController,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18.0)),
                  ),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la marca del material';
                  }
                  return null;
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
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la cantidad';
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
                ),
              ),
              const SizedBox(height: 32),
              
              // Botón de registro
              ElevatedButton(
                onPressed: _isLoading ? null : _registrarMaterial,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF193F6E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Registrar Material',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _marcaController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }
}