import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../bloc/auth_bloc.dart';

import '../../../../../core/validators/auth_validators.dart';

class RegistrarAdministradorPage extends StatefulWidget {
  const RegistrarAdministradorPage({super.key});

  @override
  State<RegistrarAdministradorPage> createState() => _RegistrarAdministradorPageState();
}

class _RegistrarAdministradorPageState extends State<RegistrarAdministradorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _primerApellidoController = TextEditingController();
  final _segundoApellidoController = TextEditingController();
  final _celularController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();

  bool _cargando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8FF),
        title: const Text('Registrar Nuevo Administrador'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() {
              _cargando = true;
            });
          } else if (state is AuthSuccess) {
            setState(() {
              _cargando = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Administrador registrado con éxito'),
                backgroundColor: Colors.green,
              ),
            );
            // Limpiar el formulario y regresar
            _limpiarFormulario();
            Navigator.pop(context);
          } else if (state is AuthError) {
            setState(() {
              _cargando = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
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
                // Logo o imagen
                Center(
                  child: Image.asset(
                    'assets/images/Logo-SAT.png',
                    height: 100,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Nombre
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
                
                // Primer Apellido
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
                
                // Segundo Apellido
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
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Celular
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
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: AuthValidators.validatePhone,
                ),
                const SizedBox(height: 16),
                
                // Correo Electrónico
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
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: AuthValidators.validateEmail,
                ),
                const SizedBox(height: 16),
                
                // Contraseña
                TextFormField(
                  controller: _contrasenaController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    ),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: AuthValidators.validatePassword,
                ),
                const SizedBox(height: 16),
                
                // Confirmar Contraseña
                TextFormField(
                  controller: _confirmarContrasenaController,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    ),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Debe confirmar la contraseña';
                    }
                    if (value != _contrasenaController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Botón de Registro
                ElevatedButton.icon(
                  onPressed: _cargando
                      ? null
                      : _registrarAdministrador,
                  icon: _cargando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.person_add),
                  label: const Text('Registrar Administrador'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF193F6E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Método personalizado para registrar administrador sin cambiar la sesión actual
  Future<void> _registrarAdministrador() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      // Guardar el usuario actual antes de registrar el nuevo administrador
      final FirebaseAuth auth = FirebaseAuth.instance;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      
      // Obtener el usuario actual
      User? currentUser = auth.currentUser;
      String? currentEmail = currentUser?.email;
      
      // Verificar si el correo ya existe
      final methods = await auth.fetchSignInMethodsForEmail(_correoController.text);
      if (methods.isNotEmpty) {
        setState(() {
          _cargando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El correo ya está registrado'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Crear un objeto AuthCredential para el usuario actual
      // Nota: No podemos obtener la contraseña actual, por lo que este enfoque
      // requiere una solución alternativa

      // Crear un nuevo administrador desconectando temporalmente al usuario actual
      if (currentUser != null) {
        // Guardar la sesión del usuario actual (solo podemos guardar el email)
        // Creamos una segunda instancia de FirebaseAuth para el nuevo usuario
        // Este enfoque es conceptual, ya que Firebase no permite múltiples instancias
        
        // En su lugar, desconectamos al usuario actual temporalmente
        await auth.signOut();
      }
      
      // Crear el nuevo administrador
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: _correoController.text,
        password: _contrasenaController.text,
      );
      
      // Guardar datos del administrador en Firestore
      await firestore.collection('administradores').doc(userCredential.user!.uid).set({
        'nombreAdm': _nombreController.text,
        'primerApellidoAdm': _primerApellidoController.text,
        'segundoApellidoAdm': _segundoApellidoController.text.isEmpty
            ? null
            : _segundoApellidoController.text,
        'celularAdm': _celularController.text,
        'correoAdm': _correoController.text,
      });
      
      // Volver a iniciar sesión con el usuario original
      if (currentEmail != null) {
        // Para este punto necesitamos la contraseña original, lo cual es un problema
        // ya que Firebase no nos permite obtenerla
        
        // Una opción es pedir la contraseña actual al administrador antes de registrar
        // otra opción es implementar tokens personalizados con Firebase Admin SDK
        
        // Por simplicidad, podríamos:
        // 1. Mostrar un mensaje de éxito
        // 2. Cerrar sesión completamente
        // 3. Redirigir a la pantalla de login
        
        await auth.signOut();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Administrador registrado correctamente. Por favor, inicie sesión nuevamente.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Opcional: redirigir a la pantalla de login
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        // Si no había usuario previo, simplemente mostramos el mensaje de éxito
        setState(() {
          _cargando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Administrador registrado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _cargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar administrador: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _primerApellidoController.clear();
    _segundoApellidoController.clear();
    _celularController.clear();
    _correoController.clear();
    _contrasenaController.clear();
    _confirmarContrasenaController.clear();
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