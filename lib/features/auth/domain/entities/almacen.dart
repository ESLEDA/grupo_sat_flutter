import 'package:equatable/equatable.dart';

class Almacen extends Equatable {
  final String id;
  final int idAlmacen;
  final String nombreAlmacen;

  const Almacen({
    required this.id,
    required this.idAlmacen,
    required this.nombreAlmacen,
  });

  @override
  List<Object?> get props => [
    id,
    idAlmacen,
    nombreAlmacen,
  ];

  // Factory para crear un Almacen desde un documento de Firestore
  factory Almacen.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Almacen(
      id: documentId,
      idAlmacen: data['idAlmacen'] ?? 0,
      nombreAlmacen: data['nombreAlmacen'] ?? '',
    );
  }

  // Método para convertir a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'idAlmacen': idAlmacen,
      'nombreAlmacen': nombreAlmacen,
    };
  }
}