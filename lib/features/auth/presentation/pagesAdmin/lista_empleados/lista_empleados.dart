import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ListaEmpleadosPage extends StatefulWidget {
  const ListaEmpleadosPage({super.key});

  @override
  State<ListaEmpleadosPage> createState() => _ListaEmpleadosPageState();
}

class _ListaEmpleadosPageState extends State<ListaEmpleadosPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  bool _isGeneratingPdf = false;
  List<Map<String, dynamic>> _empleados = [];

  @override
  void initState() {
    super.initState();
    _cargarEmpleados();
  }

  Future<void> _cargarEmpleados() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Obtener documentos de la colección 'empleados'
      final QuerySnapshot snapshot = await _firestore.collection('empleados').get();
      
      // Convertir documentos a lista de mapas
      final List<Map<String, dynamic>> empleados = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
      
      setState(() {
        _empleados = empleados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Mostrar error
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar empleados: $e')),
      );
    }
  }

  // Genera el documento PDF con la lista de empleados
  pw.Document _generatePdfDocument() {
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
                child: pw.Text('Lista de Empleados'),
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
                        child: pw.Text('Correo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Celular', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Filas de la tabla con los empleados
                  ..._empleados.map((empleado) {
                    final String nombre = empleado['nombreEmpleado'] ?? '';
                    final String primerApellido = empleado['primerApellido'] ?? '';
                    final String? segundoApellido = empleado['segundoApellido'];
                    final String nombreCompleto = segundoApellido != null && segundoApellido.isNotEmpty
                        ? '$nombre $primerApellido $segundoApellido'
                        : '$nombre $primerApellido';
                    final String correo = empleado['correo'] ?? '';
                    final String celular = empleado['celular'] ?? '';
                    
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(nombreCompleto),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(correo),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(celular),
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

  // Muestra el diálogo para previsualizar e imprimir o guardar PDF
  Future<void> _showPrintPreview() async {
    if (_isGeneratingPdf) return;
    
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final pdf = _generatePdfDocument();
      final pdfBytes = await pdf.save();

      if (!mounted) return;

      // Navegamos a una pantalla nueva para mostrar la vista previa e imprimir
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Vista previa de la lista'),
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
            const Text('Lista de Empleados'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isGeneratingPdf ? null : _showPrintPreview,
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
              label: const Text('Generar PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD7282F),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        toolbarHeight: 110,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Lista de empleados
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _empleados.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay empleados registrados',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _cargarEmpleados,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _empleados.length,
                          itemBuilder: (context, index) {
                            final empleado = _empleados[index];
                            return EmpleadoCard(empleado: empleado);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class EmpleadoCard extends StatelessWidget {
  final Map<String, dynamic> empleado;

  const EmpleadoCard({
    super.key,
    required this.empleado,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener datos del empleado
    final String nombre = empleado['nombreEmpleado'] ?? '';
    final String primerApellido = empleado['primerApellido'] ?? '';
    final String? segundoApellido = empleado['segundoApellido'];
    final String celular = empleado['celular'] ?? '';
    final String correo = empleado['correo'] ?? '';
    
    // Construir nombre completo
    final String nombreCompleto = segundoApellido != null && segundoApellido.isNotEmpty
        ? '$nombre $primerApellido $segundoApellido'
        : '$nombre $primerApellido';

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          // Contenedor superior con nombre
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
                    Icons.person,
                    color: Color(0xFF193F6E),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    nombreCompleto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Contenedor inferior con datos
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información de contacto
                Row(
                  children: [
                    const Icon(Icons.email, size: 20, color: Color(0xFF193F6E)),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        correo,
                        style: const TextStyle(fontSize: 14.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 20, color: Color(0xFF193F6E)),
                    const SizedBox(width: 8.0),
                    Text(
                      celular,
                      style: const TextStyle(fontSize: 14.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}