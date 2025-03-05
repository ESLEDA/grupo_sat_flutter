import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../bloc/marca_bloc.dart';
import '../../../domain/entities/marca.dart';
import 'registrar_marca_page.dart';

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
    // Cargar las marcas al iniciar la página
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lista de Marcas'),
            const SizedBox(height: 4),
            
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistrarMarcaPage(),
                      ),
                    ).then((_) {
                      // Recargar las marcas cuando vuelva
                      // ignore: use_build_context_synchronously
                      context.read<MarcaBloc>().add(LoadMarcas());
                    });
                  },
                  icon: const Icon(CupertinoIcons.add),
                  label: const Text('Nueva Marca'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF193F6E),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                BlocBuilder<MarcaBloc, MarcaState>(
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
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        toolbarHeight: 120, // Aumentar la altura para acomodar los botones
      ),
      body: BlocBuilder<MarcaBloc, MarcaState>(
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
          } else if (state is MarcaOperationFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MarcaBloc>().add(LoadMarcas());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No hay información disponible'));
          }
        },
      ),
      // Eliminamos el FAB porque ahora los botones están en el AppBar
    );
  }
}

class MarcaCard extends StatelessWidget {
  final Marca marca;

  const MarcaCard({
    super.key,
    required this.marca,
  });

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
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
               
              ],
            ),
          ),
          
          // Contenido de la tarjeta
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modelo
                Row(
                  children: [
                    const Icon(Icons.model_training, 
                      size: 20, 
                      color: Color(0xFF193F6E)
                    ),
                    const SizedBox(width: 8.0),
                    const Text(
                      'Modelo:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        marca.modeloDeLaMarca,
                        style: const TextStyle(fontSize: 14.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                
                // Fabricante
                Row(
                  children: [
                    const Icon(Icons.factory, 
                      size: 20, 
                      color: Color(0xFF193F6E)
                    ),
                    const SizedBox(width: 8.0),
                    const Text(
                      'Fabricante:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        marca.fabricanteDeLaMarca,
                        style: const TextStyle(fontSize: 14.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Botones de acción
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botón de editar
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF193F6E)),
                  onPressed: () {
                    // Aquí podríamos implementar la edición
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edición no implementada aún')),
                    );
                  },
                ),
                // Botón de eliminar
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Mostrar diálogo de confirmación
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
                              // Eliminar marca
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