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
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isRegistering = false;
  String _errorMessage = '';

  String? _validateConfirmPassword(String? value) {
    if (value != _contrasenaController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }
  
  // Validar correo electrónico mientras se escribe
  void _checkEmailExistence(String email) {
    if (AuthValidators.validateEmail(email) == null) {
      context.read<AuthBloc>().add(CheckEmailExists(email));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            setState(() {
              _isRegistering = false;
              _errorMessage = '';
            });
            
            if (state.userType == 'empleado_registrado') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Registro exitoso, inicia sesión con tus credenciales'),
                  backgroundColor: Colors.green,
                ),
              );
              
              // Navegar al login inmediatamente
              Navigator.pushReplacementNamed(context, '/');
            }
          } else if (state is AuthError) {
            setState(() {
              _isRegistering = false;
              _errorMessage = state.message;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is EmailExistsState) {
            if (state.exists) {
              setState(() {
                _errorMessage = 'El correo ya está registrado';
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('El correo ya está registrado'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
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
                title: const Text(
                  'Registro',
                  style: TextStyle(
                    color: Color(0xFF444957),
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                background: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/Logo-SAT.png',
                        height: 62,
                      ),
                      const SizedBox(height: 30),
                    ],
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
                      // Mostrar mensaje de error si existe
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: Colors.red.shade300),
                            ),
                            child: Text(
                              _errorMessage,
                              style: TextStyle(color: Colors.red.shade800),
                            ),
                          ),
                        ),
                      
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          prefixIcon: Icon(Icons.person, color: Color(0xFF193F6E)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
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
                          prefixIcon: Icon(Icons.person_outline, color: Color(0xFF193F6E)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
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
                          prefixIcon: Icon(Icons.person_outline, color: Color(0xFF193F6E)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _celularController,
                        decoration: const InputDecoration(
                          labelText: 'Celular',
                          prefixIcon: Icon(Icons.phone_android, color: Color(0xFF193F6E)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: AuthValidators.validatePhone,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _correoController,
                        decoration: const InputDecoration(
                          labelText: 'Correo Electrónico',
                          prefixIcon: Icon(Icons.email, color: Color(0xFF193F6E)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: AuthValidators.validateEmail,
                        onChanged: _checkEmailExistence,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contrasenaController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock, color: Color(0xFF193F6E)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF193F6E),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: AuthValidators.validatePassword,
                      ),
                      // Texto informativo sobre requisitos de contraseña
                      Container(
                        padding: const EdgeInsets.only(left: 12, top: 8),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('La contraseña debe cumplir con los siguientes requisitos:',
                                style: TextStyle(fontSize: 12, color: Colors.grey)),
                            SizedBox(height: 4),
                            Text('• Debe contener al menos 8 caracteres.',
                                style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('• Debe contener al menos un número.',
                                style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('• Debe contener al menos una letra mayúscula.',
                                style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('• Debe contener al menos un carácter especial (#,%,&,+).',
                                style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmarContrasenaController,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF193F6E)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF193F6E),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
                        validator: _validateConfirmPassword,
                      ),
                      const SizedBox(height: 24),
                      _isRegistering
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF193F6E),
                                foregroundColor: const Color(0xFFF5F8FF),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isRegistering = true;
                                    _errorMessage = '';
                                  });
                                  
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
                             child: const Text(
                               'Registrar',
                               style: TextStyle(
                                 fontSize: 16,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                            ),
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