import 'package:equatable/equatable.dart';

class Administrador extends Equatable {
  final String id;
  final String nombreAdm;
  final String primerApellidoAdm;
  final String? segundoApellidoAdm;
  final String contrasenaAdm;
  final String celularAdm;
  final String correoAdm;

  const Administrador({
    required this.id,
    required this.nombreAdm,
    required this.primerApellidoAdm,
    this.segundoApellidoAdm,
    required this.contrasenaAdm,
    required this.celularAdm,
    required this.correoAdm,
  });

  @override
  List<Object?> get props => [
        id,
        nombreAdm,
        primerApellidoAdm,
        segundoApellidoAdm,
        contrasenaAdm,
        celularAdm,
        correoAdm,
      ];
}