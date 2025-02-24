import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/validators/auth_validators.dart';
import '../bloc/auth_bloc.dart';
import '../../domain/entities/empleado.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistroPageState createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
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
        title: const Text('Registro de Empleado'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registro exitoso')),
            );
            Navigator.pop(context); // Volver a la página de login
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
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
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
                    border: OutlineInputBorder(),
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
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _celularController,
                  decoration: const InputDecoration(
                    labelText: 'Celular',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: AuthValidators.validatePhone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _correoController,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: AuthValidators.validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contrasenaController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: AuthValidators.validatePassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmarContrasenaController,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    border: OutlineInputBorder(),
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
                    return ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final empleado = Empleado(
                            id: '', // Se generará en Firebase
                            nombreEmpleado: _nombreController.text,
                            primerApellido: _primerApellidoController.text,
                            segundoApellido: _segundoApellidoController.text.isEmpty 
                                ? null 
                                : _segundoApellidoController.text,
                            contrasena: _contrasenaController.text,
                            celular: _celularController.text,
                            correo: _correoController.text,
                          );
                          context.read<AuthBloc>().add(RegisterEmpleadoRequested(empleado));
                        }
                      },
                      child: const Text('Registrar'),
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