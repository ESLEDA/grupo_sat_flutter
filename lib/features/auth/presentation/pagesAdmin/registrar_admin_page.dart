import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../domain/entities/administrador.dart';
import '../bloc/auth_bloc.dart';

class RegistrarAdminPage extends StatefulWidget {
  const RegistrarAdminPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrarAdminPageState createState() => _RegistrarAdminPageState();
}

class _RegistrarAdminPageState extends State<RegistrarAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _primerApellidoController = TextEditingController();
  final _segundoApellidoController = TextEditingController();
  final _celularController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();

  String? _validateConfirmPassword(String? value) {
    if (value != _contrasenaController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Administrador'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Administrador registrado con éxito')),
            );
            Navigator.pop(context); // Volver a la página anterior
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Información del Administrador',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Hace los bordes más curvos
                          ),
                          enabledBorder:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Mantiene la curvatura cuando no está enfocado
                          ),
                          focusedBorder:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Mantiene la curvatura cuando está enfocado
                          ),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _primerApellidoController,
                  decoration: const InputDecoration(
                    labelText: 'Primer Apellido',
                    border:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Hace los bordes más curvos
                          ),
                          enabledBorder:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Mantiene la curvatura cuando no está enfocado
                          ),
                          focusedBorder:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Mantiene la curvatura cuando está enfocado
                          ),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El primer apellido es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _segundoApellidoController,
                  decoration: const InputDecoration(
                    labelText: 'Segundo Apellido (Opcional)',
                    border:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Hace los bordes más curvos
                          ),
                          enabledBorder:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Mantiene la curvatura cuando no está enfocado
                          ),
                          focusedBorder:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Mantiene la curvatura cuando está enfocado
                          ),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _celularController,
                  decoration: const InputDecoration(
                    labelText: 'Celular',
                    border:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Hace los bordes más curvos
                          ),
                          enabledBorder:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Mantiene la curvatura cuando no está enfocado
                          ),
                          focusedBorder:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Mantiene la curvatura cuando está enfocado
                          ),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: AuthValidators.validatePhone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _correoController,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    border:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Hace los bordes más curvos
                          ),
                          enabledBorder:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Mantiene la curvatura cuando no está enfocado
                          ),
                          focusedBorder:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Mantiene la curvatura cuando está enfocado
                          ),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: AuthValidators.validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contrasenaController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Hace los bordes más curvos
                          ),
                          enabledBorder:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Mantiene la curvatura cuando no está enfocado
                          ),
                          focusedBorder:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Mantiene la curvatura cuando está enfocado
                          ),
                    prefixIcon: Icon(Icons.lock),
                    helperText: 'Al menos 8 caracteres, una mayúscula, un número y un carácter especial (#,%,&,+)',
                  ),
                  obscureText: true,
                  validator: AuthValidators.validatePassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmarContrasenaController,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    border:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Hace los bordes más curvos
                          ),
                          enabledBorder:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Mantiene la curvatura cuando no está enfocado
                          ),
                          focusedBorder:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Mantiene la curvatura cuando está enfocado
                          ),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final administrador = Administrador(
                            id: '', // Se generará en Firebase
                            nombreAdm: _nombreController.text,
                            primerApellidoAdm: _primerApellidoController.text,
                            segundoApellidoAdm: _segundoApellidoController.text.isEmpty 
                                ? null 
                                : _segundoApellidoController.text,
                            celularAdm: _celularController.text,
                            contrasenaAdm: _contrasenaController.text,
                            correoAdm: _correoController.text,
                          );
                          context.read<AuthBloc>().add(RegisterAdminRequested(administrador));
                        }
                      },
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text('Registrar Administrador'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _primerApellidoController.dispose();
    _segundoApellidoController.dispose();
    _celularController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }
}