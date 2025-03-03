import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/marca.dart';

class MarcaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener todas las marcas
  Stream<List<Marca>> getMarcas() {
    return _firestore
        .collection('marcas')
        .orderBy('idMarca')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Marca.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Registrar una nueva marca
  Future<void> registrarMarca(Marca marca) async {
    try {
      // Obtener el último ID para autoincremento
      int nuevoId = 1;
      final QuerySnapshot snapshot = await _firestore
          .collection('marcas')
          .orderBy('idMarca', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final lastDoc = snapshot.docs.first.data() as Map<String, dynamic>;
        nuevoId = (lastDoc['idMarca'] ?? 0) + 1;
      }

      // Crear nueva marca con ID autoincrementado
      final nuevaMarca = Marca(
        id: '', // Se generará en Firestore
        idMarca: nuevoId,
        nombreMarca: marca.nombreMarca,
        modeloDeLaMarca: marca.modeloDeLaMarca,
        fabricanteDeLaMarca: marca.fabricanteDeLaMarca,
      );

      // Guardar en Firestore
      await _firestore.collection('marcas').add(nuevaMarca.toFirestore());
    } catch (e) {
      throw Exception('Error al registrar marca: $e');
    }
  }

  // Actualizar una marca existente
  Future<void> actualizarMarca(Marca marca) async {
    try {
      await _firestore
          .collection('marcas')
          .doc(marca.id)
          .update(marca.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar marca: $e');
    }
  }

  // Eliminar una marca
  Future<void> eliminarMarca(String marcaId) async {
    try {
      await _firestore.collection('marcas').doc(marcaId).delete();
    } catch (e) {
      throw Exception('Error al eliminar marca: $e');
    }
  }
}