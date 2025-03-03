import 'package:equatable/equatable.dart';

class Marca extends Equatable {
  final String id;
  final int idMarca;
  final String nombreMarca;
  final String modeloDeLaMarca;
  final String fabricanteDeLaMarca;

  const Marca({
    required this.id,
    required this.idMarca,
    required this.nombreMarca,
    required this.modeloDeLaMarca,
    required this.fabricanteDeLaMarca,
  });

  @override
  List<Object?> get props => [
    id,
    idMarca,
    nombreMarca,
    modeloDeLaMarca,
    fabricanteDeLaMarca,
  ];

  // Factory para crear una Marca desde un documento de Firestore
  factory Marca.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Marca(
      id: documentId,
      idMarca: data['idMarca'] ?? 0,
      nombreMarca: data['nombreMarca'] ?? '',
      modeloDeLaMarca: data['modeloDeLaMarca'] ?? '',
      fabricanteDeLaMarca: data['fabricanteDeLaMarca'] ?? '',
    );
  }

  // Método para convertir a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'idMarca': idMarca,
      'nombreMarca': nombreMarca,
      'modeloDeLaMarca': modeloDeLaMarca,
      'fabricanteDeLaMarca': fabricanteDeLaMarca,
    };
  }
}