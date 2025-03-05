import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../bloc/marca_bloc.dart';
import '../../../domain/entities/marca.dart';
import 'registrar_marca_page.dart';
import 'editar_marca_page.dart';

class MarcasPage extends StatefulWidget {
  const MarcasPage({super.key});

  @override
  State<MarcasPage> createState() => _MarcasPageState();
}

class _MarcasPageState extends State<MarcasPage> {
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    context.read<MarcaBloc>().add(LoadMarcas());
  }

  // Método para generar el PDF con la lista de marcas
  pw.Document _generatePdfDocument(List<Marca> marcas) {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Lista de Marcas'),
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
                        child: pw.Text('Modelo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Fabricante', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Filas de la tabla con las marcas
                  ...marcas.map((marca) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(marca.nombreMarca),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(marca.modeloDeLaMarca),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(marca.fabricanteDeLaMarca),
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

  // Mostrar vista previa del PDF para imprimir o guardar
  Future<void> _showPrintPreview(List<Marca> marcas) async {
    if (_isGeneratingPdf) return;
    
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final pdf = _generatePdfDocument(marcas);
      final pdfBytes = await pdf.save();

      if (!mounted) return;

      // Navegamos a una pantalla nueva para mostrar la vista previa e imprimir
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Vista previa de marcas'),
            ),
            body: PdfPreview(
              build: (format) => pdfBytes,
              allowPrinting: true,
              allowSharing: true,
              canChangeOrientation: false,
              canChangePageFormat: false,
              initialPageFormat: PdfPageFormat.a4,
            ),
          ),
        ),
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
            Text('Lista de Marcas'),
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
                          builder: (context) => const RegistrarMarcaPage(),
                        ),
                      ).then((_) {
                        // Recargar las marcas cuando vuelva
                        context.read<MarcaBloc>().add(LoadMarcas());
                      });
                    },
                    icon: const Icon(CupertinoIcons.add),
                    label: const Text('Nueva Marca'),
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
                  child: BlocBuilder<MarcaBloc, MarcaState>(
                    builder: (context, state) {
                      return ElevatedButton.icon(
                        onPressed: (state is MarcasLoaded && !_isGeneratingPdf) 
                            ? () => _showPrintPreview(state.marcas)
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
                          : const Icon(CupertinoIcons.doc_text),
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
          
          // Contenido principal
          Expanded(
            child: BlocBuilder<MarcaBloc, MarcaState>(
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
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<MarcaBloc>().add(LoadMarcas());
                            return;
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: marcas.length,
                            itemBuilder: (context, index) {
                              final marca = marcas[index];
                              return MarcaCard(marca: marca);
                            },
                          ),
                        );
                } else {
                  return const Center(child: Text('Error al cargar marcas'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MarcaCard extends StatelessWidget {
  final Marca marca;

  const MarcaCard({super.key, required this.marca});

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
          
          // Información de la marca
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
                          const Icon(Icons.model_training, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text('Modelo: ${marca.modeloDeLaMarca}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.factory, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text('Fabricante: ${marca.fabricanteDeLaMarca}'),
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
                        builder: (context) => EditarMarcaPage(marca: marca),
                      ),
                    );
                    if (resultado != null) {
                      context.read<MarcaBloc>().add(LoadMarcas());
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
                        title: const Text('Eliminar marca'),
                        content: Text('¿Está seguro de eliminar la marca ${marca.nombreMarca}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
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