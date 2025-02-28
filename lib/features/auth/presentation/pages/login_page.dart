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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F8FF),//0xFFF5F8FF
          centerTitle: true,
          automaticallyImplyLeading: false, // Quita el botón de retroceso si no lo necesitas
          toolbarHeight: 120, // Ajusta este valor según el tamaño de tu logo (60) + texto + algo de espacio
          title: const Column(
            mainAxisSize: MainAxisSize.min, // Esto hace que la columna ocupe solo el espacio necesario
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
            if (state.userType == 'admin') {
              Navigator.pushReplacementNamed(context, '/admin');
            } else {
              Navigator.pushReplacementNamed(context, '/empleado');
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Center(
        
            child: SingleChildScrollView(
               padding: const EdgeInsets.only(
                 top: 10.0, // Reduce este valor para acercar los elementos al AppBar
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
                    
                    
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
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
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Hace los bordes más curvos
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Mantiene la curvatura cuando no está enfocado
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18.0)), // Mantiene la curvatura cuando está enfocado
                          ),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ?  Icons.visibility_off : Icons.visibility,
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
                    const SizedBox(height: 24),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
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
                          ),
                          child: const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFF5F8FF), // Añade esta línea para el color del texto
                          ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿No tienes cuenta?',
                          
                        ),
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