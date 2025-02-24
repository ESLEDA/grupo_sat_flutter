import 'package:equatable/equatable.dart';

class Empleado extends Equatable {
  final String id;
  final String nombreEmpleado;
  final String primerApellido;
  final String? segundoApellido;
  final String contrasena;
  final String celular;
  final String correo;

  const Empleado({
    required this.id,
    required this.nombreEmpleado,
    required this.primerApellido,
    this.segundoApellido,
    required this.contrasena,
    required this.celular,
    required this.correo,
  });

  @override
  List<Object?> get props => [
        id,
        nombreEmpleado,
        primerApellido,
        segundoApellido,
        contrasena,
        celular,
        correo,
      ];
}