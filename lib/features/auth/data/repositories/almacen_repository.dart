import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/almacen.dart';

class AlmacenRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener todos los almacenes
  Stream<List<Almacen>> getAlmacenes() {
    return _firestore
        .collection('almacenes')
        .orderBy('idAlmacen')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Almacen.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Registrar un nuevo almacén
  Future<void> registrarAlmacen(Almacen almacen) async {
    try {
      // Obtener el último ID para autoincremento
      int nuevoId = 1;
      final QuerySnapshot snapshot = await _firestore
          .collection('almacenes')
          .orderBy('idAlmacen', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final lastDoc = snapshot.docs.first.data() as Map<String, dynamic>;
        nuevoId = (lastDoc['idAlmacen'] ?? 0) + 1;
      }

      // Crear nuevo almacén con ID autoincrementado
      final nuevoAlmacen = Almacen(
        id: '', // Se generará en Firestore
        idAlmacen: nuevoId,
        nombreAlmacen: almacen.nombreAlmacen,
      );

      // Guardar en Firestore
      await _firestore.collection('almacenes').add(nuevoAlmacen.toFirestore());
    } catch (e) {
      throw Exception('Error al registrar almacén: $e');
    }
  }

  // Actualizar un almacén existente
  Future<void> actualizarAlmacen(Almacen almacen) async {
    try {
      await _firestore
          .collection('almacenes')
          .doc(almacen.id)
          .update(almacen.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar almacén: $e');
    }
  }

  // Eliminar un almacén
  Future<void> eliminarAlmacen(String almacenId) async {
    try {
      await _firestore.collection('almacenes').doc(almacenId).delete();
    } catch (e) {
      throw Exception('Error al eliminar almacén: $e');
    }
  }
}