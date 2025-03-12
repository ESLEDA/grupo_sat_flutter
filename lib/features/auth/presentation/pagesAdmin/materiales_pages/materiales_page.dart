import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../features/auth/presentation/bloc/material_bloc.dart' as material_bloc;
import '../../../../../features/auth/presentation/bloc/almacen_bloc.dart';
import '../../../../../features/auth/domain/entities/almacen.dart';
import 'registrar_material_page.dart';
import 'editar_material_page.dart';
import '../../../domain/entities/material.dart' as app_material;

class MaterialesPage extends StatefulWidget {
  const MaterialesPage({super.key});

  @override
  State<MaterialesPage> createState() => _MaterialesPageState();
}

class _MaterialesPageState extends State<MaterialesPage> {
  bool _isGeneratingPdf = false;
  String? _almacenSeleccionado; // Para filtrar materiales por almacén
  List<Almacen> _listaAlmacenes = []; // Lista de almacenes disponibles
  bool _isCargandoAlmacenes = true;

  @override
  void initState() {
    super.initState();
    context.read<material_bloc.MaterialBloc>().add(material_bloc.LoadMateriales());
    context.read<AlmacenBloc>().add(LoadAlmacenes()); // Cargar almacenes
  }

  // Método para generar el PDF con la lista de materiales
  pw.Document _generatePdfDocument(List<app_material.Material> materiales) {
    final pdf = pw.Document();

    // Filtrar materiales por almacén si hay uno seleccionado
    final materialesFiltrados = _almacenSeleccionado != null
        ? materiales.where((m) => m.almacen == _almacenSeleccionado).toList()
        : materiales;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Lista de Materiales' + (_almacenSeleccionado != null ? ' - Almacén: $_almacenSeleccionado' : '')),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Encabezado de la tabla
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Nombre', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Marca', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Cantidad', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Almacén', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Filas de la tabla con los materiales filtrados
                  ...materialesFiltrados.map((material) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(material.nombreMaterial),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(material.marcaMaterial),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(material.cantidadUnidades.toString()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(material.almacen),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Generado el ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  // Generar y compartir el PDF
  Future<void> _generateAndSharePdf(List<app_material.Material> materiales) async {
    if (_isGeneratingPdf) return;
    
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final pdf = _generatePdfDocument(materiales);
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'materiales_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      
      // Guardar el PDF en el almacenamiento
      await file.writeAsBytes(await pdf.save());
      
      if (!mounted) return;

      // Mostrar opciones para compartir el PDF
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Lista de Materiales' + (_almacenSeleccionado != null ? ' - Almacén: $_almacenSeleccionado' : ''),
        text: 'Compartir PDF de materiales'
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar el PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGeneratingPdf = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8FF),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lista de Materiales'),
            SizedBox(height: 4),
          ],
        ),
        toolbarHeight: 70,
      ),
      body: Column(
        children: [
          // Fila de botones
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistrarMaterialPage(),
                        ),
                      ).then((_) {
                        // Recargar los materiales cuando vuelva
                        context.read<material_bloc.MaterialBloc>().add(material_bloc.LoadMateriales());
                      });
                    },
                    icon: const Icon(CupertinoIcons.add),
                    label: const Text('Nuevo Material'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF193F6E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 120,
                  child: BlocBuilder<material_bloc.MaterialBloc, material_bloc.MaterialState>(
                    builder: (context, state) {
                      return ElevatedButton.icon(
                        onPressed: (state is material_bloc.MaterialesLoaded && !_isGeneratingPdf) 
                            ? () => _generateAndSharePdf(state.materiales)
                            : null,
                        icon: _isGeneratingPdf 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(CupertinoIcons.share),
                        label: const Text('PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD7282F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Selector de almacén
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: BlocListener<AlmacenBloc, AlmacenState>(
              listener: (context, state) {
                if (state is AlmacenesLoaded) {
                  setState(() {
                    _listaAlmacenes = state.almacenes;
                    _isCargandoAlmacenes = false;
                  });
                }
              },
              child: _isCargandoAlmacenes
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.0),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          isExpanded: true,
                          value: _almacenSeleccionado,
                          hint: const Text('Seleccionar almacén'),
                          iconEnabledColor: const Color(0xFF193F6E),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Todos los almacenes'),
                            ),
                            ..._listaAlmacenes.map((almacen) {
                              return DropdownMenuItem<String?>(
                                value: almacen.nombreAlmacen,
                                child: Text(almacen.nombreAlmacen),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _almacenSeleccionado = value;
                            });
                          },
                        ),
                      ),
                    ),
            ),
          ),
          
          // Contenido principal
          Expanded(
            child: BlocBuilder<material_bloc.MaterialBloc, material_bloc.MaterialState>(
              builder: (context, state) {
                if (state is material_bloc.MaterialLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is material_bloc.MaterialesLoaded) {
                  final materiales = state.materiales;
                  
                  // Filtrar materiales por almacén si hay uno seleccionado
                  final materialesFiltrados = _almacenSeleccionado != null
                      ? materiales.where((m) => m.almacen == _almacenSeleccionado).toList()
                      : materiales;
                  
                  return materialesFiltrados.isEmpty
                      ? Center(
                          child: Text(
                            _almacenSeleccionado == null
                                ? 'No hay materiales registrados'
                                : 'No hay materiales en el almacén $_almacenSeleccionado',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<material_bloc.MaterialBloc>().add(material_bloc.LoadMateriales());
                            return;
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: materialesFiltrados.length,
                            itemBuilder: (context, index) {
                              final material = materialesFiltrados[index];
                              return MaterialCard(material: material);
                            },
                          ),
                        );
                } else {
                  return const Center(child: Text('Error al cargar materiales'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MaterialCard extends StatelessWidget {
  final app_material.Material material;

  const MaterialCard({super.key, required this.material});

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
          // Encabezado de la tarjeta con el nombre del material
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Color(0xFF193F6E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.inventory,
                    color: Color(0xFF193F6E),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    material.nombreMaterial,
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
          
          // Información del material
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.label, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text('Marca: ${material.marcaMaterial}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.numbers, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text('Cantidad: ${material.cantidadUnidades} unidades'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.warehouse, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text('Almacén: ${material.almacen}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Botones de acción
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botón de editar
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF193F6E)),
                  onPressed: () async {
                    final resultado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditarMaterialPage(material: material.toFirestore()),
                      ),
                    );
                    if (resultado != null) {
                      context.read<material_bloc.MaterialBloc>().add(material_bloc.LoadMateriales());
                    }
                  },
                ),
                // Botón de eliminar
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Eliminar material'),
                        content: Text('¿Está seguro de eliminar el material ${material.nombreMaterial}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<material_bloc.MaterialBloc>().add(material_bloc.DeleteMaterial(material));
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