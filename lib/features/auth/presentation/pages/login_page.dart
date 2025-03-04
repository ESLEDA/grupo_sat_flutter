import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/validators/auth_validators.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoggingIn = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Verificar si hay un usuario con sesión activa
    context.read<AuthBloc>().add(VerifyCurrentUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8FF),
        centerTitle: true,
        automaticallyImplyLeading: false,
        toolbarHeight: 120,
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: AssetImage('assets/images/Logo-SAT.png'),
              height: 62,
            ),
            SizedBox(height: 25),
            Text(
              'Inicio de sesión',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF444957),
              ),
            ),
          ],
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Navegar a la página correspondiente según el tipo de usuario
            setState(() {
              _isLoggingIn = false;
              _errorMessage = '';
            });
            
            if (state.userType == 'admin') {
              Navigator.pushReplacementNamed(context, '/admin');
            } else {
              Navigator.pushReplacementNamed(context, '/empleado');
            }
          } else if (state is AuthError) {
            setState(() {
              _isLoggingIn = false;
              _errorMessage = state.message;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is CurrentUserState) {
            // Si el usuario ya tiene sesión iniciada, redirigir
            if (state.userData['loggedIn'] == true) {
              String userType = state.userData['userType'];
              if (userType == 'admin') {
                Navigator.pushReplacementNamed(context, '/admin');
              } else if (userType == 'empleado') {
                Navigator.pushReplacementNamed(context, '/empleado');
              }
            }
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: 10.0,
              left: 24.0,
              right: 24.0,
              bottom: 24.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18.0)),
                      ),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: AuthValidators.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
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
                      prefixIcon: const Icon(Icons.lock),
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
                    validator: (value) {
                      // Validación menos estricta para inicio de sesión
                      if (value == null || value.isEmpty) {
                        return 'La contraseña es requerida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _isLoggingIn
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoggingIn = true;
                                _errorMessage = '';
                              });
                              
                              context.read<AuthBloc>().add(
                                LoginRequested(
                                  _emailController.text,
                                  _passwordController.text,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF193F6E),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                          ),
                          child: const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFF5F8FF),
                            ),
                          ),
                        ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿No tienes cuenta?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/registro');
                        },
                        child: const Text(
                          'Registrate',
                          style: TextStyle(
                            color: Color(0xFF193F6E),
                            fontWeight: FontWeight.bold,
                            fontSize: 15
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}