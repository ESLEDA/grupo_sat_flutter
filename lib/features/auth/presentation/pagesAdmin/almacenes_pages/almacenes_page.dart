import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../bloc/almacen_bloc.dart';
import '../../../domain/entities/almacen.dart';
import 'registrar_almacen_page.dart';

class AlmacenesPage extends StatefulWidget {
  const AlmacenesPage({super.key});

  @override
  State<AlmacenesPage> createState() => _AlmacenesPageState();
}

class _AlmacenesPageState extends State<AlmacenesPage> {
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    // Cargar los almacenes al iniciar la página
    context.read<AlmacenBloc>().add(LoadAlmacenes());
  }

  // Método para generar el PDF con la lista de almacenes
  pw.Document _generatePdfDocument(List<Almacen> almacenes) {
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
                child: pw.Text('Lista de Almacenes'),
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
                        child: pw.Text('Nombre del Almacén', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Filas de la tabla con los almacenes
                  ...almacenes.map((almacen) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(almacen.nombreAlmacen),
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
  Future<void> _showPrintPreview(List<Almacen> almacenes) async {
    if (_isGeneratingPdf) return;
    
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final pdf = _generatePdfDocument(almacenes);
      final pdfBytes = await pdf.save();

      if (!mounted) return;

      // Navegamos a una pantalla nueva para mostrar la vista previa e imprimir
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Vista previa de almacenes'),
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
            Text('Lista de Almacenes'),
            SizedBox(height: 4),
          ],
        ),
        toolbarHeight: 70, // Reducido para evitar overflow
      ),
      body: Column(
        children: [
          // Fila de botones movida fuera del AppBar
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
                          builder: (context) => const RegistrarAlmacenPage(),
                        ),
                      ).then((_) {
                        // Recargar los almacenes cuando vuelva
                        context.read<AlmacenBloc>().add(LoadAlmacenes());
                      });
                    },
                    icon: const Icon(CupertinoIcons.add),
                    label: const Text('Nuevo Almacén'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF193F6E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 120, // Ancho fijo para el botón PDF
                  child: BlocBuilder<AlmacenBloc, AlmacenState>(
                    builder: (context, state) {
                      return ElevatedButton.icon(
                        onPressed: (state is AlmacenesLoaded && !_isGeneratingPdf) 
                            ? () => _showPrintPreview(state.almacenes)
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
            child: BlocBuilder<AlmacenBloc, AlmacenState>(
              builder: (context, state) {
                if (state is AlmacenLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AlmacenesLoaded) {
                  final almacenes = state.almacenes;
                  
                  return almacenes.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay almacenes registrados',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<AlmacenBloc>().add(LoadAlmacenes());
                            return;
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: almacenes.length,
                            itemBuilder: (context, index) {
                              final almacen = almacenes[index];
                              return AlmacenCard(almacen: almacen);
                            },
                          ),
                        );
                } else if (state is AlmacenOperationFailure) {
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
                            context.read<AlmacenBloc>().add(LoadAlmacenes());
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
          ),
        ],
      ),
    );
  }
}

class AlmacenCard extends StatelessWidget {
  final Almacen almacen;

  const AlmacenCard({
    super.key,
    required this.almacen,
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
          // Encabezado de la tarjeta con el nombre del almacén
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
                    Icons.warehouse,
                    color: Color(0xFF193F6E),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    almacen.nombreAlmacen,
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
          
          // Botones de acción
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
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
                        title: const Text('Eliminar almacén'),
                        content: Text('¿Está seguro de eliminar el almacén ${almacen.nombreAlmacen}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Eliminar almacén
                              context.read<AlmacenBloc>().add(DeleteAlmacen(almacen.id));
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