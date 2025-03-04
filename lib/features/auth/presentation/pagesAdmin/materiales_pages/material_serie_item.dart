import 'package:flutter/material.dart';

class MaterialSerieItem extends StatefulWidget {
  final int index;
  final Function(int) onRemove;
  final String? numeroSerie;
  final String? unidad;

  const MaterialSerieItem({
    super.key,
    required this.index,
    required this.onRemove,
    this.numeroSerie,
    this.unidad,
  });

  String getNumeroSerie() {
    return _MaterialSerieItemState.serieControllers[index]?.text ?? '';
  }

  String getUnidad() {
    return _MaterialSerieItemState.unidadControllers[index]?.text ?? '';
  }

  @override
  State<MaterialSerieItem> createState() => _MaterialSerieItemState();
}

class _MaterialSerieItemState extends State<MaterialSerieItem> {
  // Listas estáticas para mantener los controladores entre reconstrucciones
  static final Map<int, TextEditingController> serieControllers = {};
  static final Map<int, TextEditingController> unidadControllers = {};

  late TextEditingController _serieController;
  late TextEditingController _unidadController;

  @override
  void initState() {
    super.initState();

    // Inicializar los controladores para este índice
    _serieController = TextEditingController(text: widget.numeroSerie);
    _unidadController = TextEditingController(text: widget.unidad);

    // Guardar los controladores en las listas estáticas
    serieControllers[widget.index] = _serieController;
    unidadControllers[widget.index] = _unidadController;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Unidad ${widget.index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (widget.index > 0) // Solo permitir eliminar si no es el primer elemento
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => widget.onRemove(widget.index),
                    tooltip: 'Eliminar unidad',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Campo para el tipo de unidad
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _unidadController,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Unidad',
                      hintText: 'Ej: Laptop, Mouse, etc.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18.0)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requerido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Campo para el número de serie
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _serieController,
                    decoration: const InputDecoration(
                      labelText: 'Número de Serie',
                      hintText: 'Ingrese el número de serie',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18.0)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requerido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // No eliminar los controladores aquí, ya que se necesitan entre reconstrucciones
    super.dispose();
  }
}