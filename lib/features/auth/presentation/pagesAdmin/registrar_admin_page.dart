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
  
  // Variables para controlar la visibilidad de las contraseñas
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _validateConfirmPassword(String? value) {
    if (value != _contrasenaController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
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
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 160.0,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFFF5F8FF),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 16),
                title: const Text(
                  'Añadir administrador',
                  style: TextStyle(
                    color: Color(0xFF444957),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                collapseMode: CollapseMode.pin,
                background: Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/Logo-SAT.png',
                          height: 62,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          prefixIcon: Icon(Icons.person, color: Color(0xFF193F6E)),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          prefixIcon: Icon(Icons.person_outline, color: Color(0xFF193F6E)),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          prefixIcon: Icon(Icons.person_outline, color: Color(0xFF193F6E)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _celularController,
                        decoration: const InputDecoration(
                          labelText: 'Celular',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          prefixIcon: Icon(Icons.phone, color: Color(0xFF193F6E)),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: AuthValidators.validatePhone,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _correoController,
                        decoration: const InputDecoration(
                          labelText: 'Correo Electrónico',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          prefixIcon: Icon(Icons.email, color: Color(0xFF193F6E)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: AuthValidators.validateEmail,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contrasenaController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          prefixIcon: const Icon(Icons.lock, color: Color(0xFF193F6E)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: AuthValidators.validatePassword,
                      ),
                      const SizedBox(height: 4), 
                      const Text('La contraseña debe cumplir con los siguientes requisitos:',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      const Text('• Debe contener al menos 8 caracteres.',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const Text('• Debe contener al menos un número.',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const Text('• Debe contener al menos una letra mayúscula.',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const Text('• Debe contener al menos un carácter especial (#,%,&,+).',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmarContrasenaController,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Contraseña',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF193F6E)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
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
                            icon: const Icon(
                              Icons.admin_panel_settings,
                              color: Color(0xFFF5F8FF)),
                            label: const Text(
                              'Registrar Administrador',
                              style: TextStyle(
                                color: Color(0xFFF5F8FF),
                                fontWeight: FontWeight.bold,
                              )),
                            style: ElevatedButton.styleFrom(
                               backgroundColor: const Color(0xFF193F6E),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
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