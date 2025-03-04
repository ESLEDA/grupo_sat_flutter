import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/material.dart';

class MaterialRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener todos los materiales
  Stream<List<Material>> getMateriales() {
    return _firestore
        .collection('materiales')
        .orderBy('nombreMaterial')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Material.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Registrar un nuevo material
  Future<void> registrarMaterial(Material material) async {
    try {
      // Guardar en Firestore
      await _firestore.collection('materiales').add(material.toFirestore());
    } catch (e) {
      throw Exception('Error al registrar material: $e');
    }
  }

  // Actualizar un material existente
  Future<void> actualizarMaterial(Material material) async {
    try {
      await _firestore
          .collection('materiales')
          .doc(material.id)
          .update(material.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar material: $e');
    }
  }

  // Eliminar un material
  Future<void> eliminarMaterial(String materialId) async {
    try {
      await _firestore.collection('materiales').doc(materialId).delete();
    } catch (e) {
      throw Exception('Error al eliminar material: $e');
    }
  }
  
  // Obtener un material por su ID
  Future<Material?> getMaterialById(String materialId) async {
    try {
      final doc = await _firestore.collection('materiales').doc(materialId).get();
      if (doc.exists) {
        return Material.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener material: $e');
    }
  }
}