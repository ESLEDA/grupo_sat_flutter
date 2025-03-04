import 'package:equatable/equatable.dart';

class Material extends Equatable {
  final String id;
  final String nombreMaterial;
  final String marcaMaterial;
  final int cantidadUnidades;
  final Map<String, dynamic> numeroSerie;
  final String descripcionMaterial; // Nuevo campo agregado

  const Material({
    required this.id,
    required this.nombreMaterial,
    required this.marcaMaterial,
    required this.cantidadUnidades,
    required this.numeroSerie,
    required this.descripcionMaterial, // Agregado al constructor
  });

  @override
  List<Object?> get props => [
    id,
    nombreMaterial,
    marcaMaterial,
    cantidadUnidades,
    numeroSerie,
    descripcionMaterial, // Agregado a los props
  ];

  // Factory para crear un Material desde un documento de Firestore
  factory Material.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Material(
      id: documentId,
      nombreMaterial: data['nombreMaterial'] ?? '',
      marcaMaterial: data['marcaMaterial'] ?? '',
      cantidadUnidades: data['cantidadUnidades'] ?? 0,
      numeroSerie: data['numeroSerie'] ?? {},
      descripcionMaterial: data['descripcionMaterial'] ?? '', // Extraído de Firestore
    );
  }

  // Método para convertir a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombreMaterial': nombreMaterial,
      'marcaMaterial': marcaMaterial,
      'cantidadUnidades': cantidadUnidades,
      'numeroSerie': numeroSerie,
      'descripcionMaterial': descripcionMaterial, // Incluido en el mapa de Firestore
    };
  }
}