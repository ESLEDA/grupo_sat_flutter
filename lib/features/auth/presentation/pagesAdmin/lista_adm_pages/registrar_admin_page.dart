import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../bloc/auth_bloc.dart';
import '../../../domain/entities/administrador.dart';

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
  final _passwordActualController = TextEditingController(); // Para reautenticar

  bool _cargando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8FF),
        title: const Text('Registrar Nuevo Administrador'),
      ),
      body: SingleChildScrollView(
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
    );
  }

  // Método para solicitar la contraseña actual para reautenticación
  Future<String?> _solicitarContrasenaActual() async {
    _passwordActualController.clear();
    
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Para mantener tu sesión activa mientras registras un nuevo administrador, por favor ingresa tu contraseña actual.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordActualController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña actual',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, _passwordActualController.text),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  // Método para registrar administrador conservando la sesión actual
  Future<void> _registrarAdministrador() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      
      // Obtener el usuario actual
      User? currentUser = auth.currentUser;
      
      // Verificar si el correo ya existe
      final methods = await auth.fetchSignInMethodsForEmail(_correoController.text);
      if (methods.isNotEmpty) {
        if (!mounted) return;
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

      // Si hay un usuario actual, solicitar contraseña para reautenticar
      String? currentPassword;
      String? currentEmail = currentUser?.email;
      
      if (currentUser != null) {
        currentPassword = await _solicitarContrasenaActual();
        
        if (currentPassword == null || currentPassword.isEmpty) {
          // El usuario canceló el diálogo
          setState(() {
            _cargando = false;
          });
          return;
        }
      }

      // Preparar los datos del nuevo administrador
      String idTemporalAdmin = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Crear el nuevo administrador
      
      // Estrategia: Usar REST API para crear usuario en Firebase
      // Dado que no podemos crear usuarios sin iniciar sesión con ellos,
      // y Firebase Admin SDK no está disponible en el cliente...
      
      // Esta es una alternativa: Guardar temporalmente los datos, cerrar sesión,
      // crear el usuario, y luego volver a iniciar sesión con el usuario original
      
      // 1. Guardar temporalmente las credenciales actuales
      if (currentUser != null && currentEmail != null && currentPassword != null) {
        // 2. Cerrar sesión temporalmente
        await auth.signOut();
        
        try {
          // 3. Crear nuevo administrador
          final userCredential = await auth.createUserWithEmailAndPassword(
            email: _correoController.text,
            password: _contrasenaController.text,
          );
          
          // 4. Guardar datos en Firestore
          await firestore.collection('administradores').doc(userCredential.user!.uid).set({
            'nombreAdm': _nombreController.text,
            'primerApellidoAdm': _primerApellidoController.text,
            'segundoApellidoAdm': _segundoApellidoController.text.isEmpty
                ? null
                : _segundoApellidoController.text,
            'celularAdm': _celularController.text,
            'correoAdm': _correoController.text,
          });
          
          // 5. Cerrar sesión del nuevo administrador
          await auth.signOut();
          
          // 6. Volver a iniciar sesión con el usuario original
          await auth.signInWithEmailAndPassword(
            email: currentEmail,
            password: currentPassword,
          );
          
          // 7. Mostrar mensaje de éxito
          if (!mounted) return;
          setState(() {
            _cargando = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Administrador registrado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          
          _limpiarFormulario();
          Navigator.pop(context); // Regresar a la lista de administradores
          
        } catch (innerError) {
          // Si ocurre un error durante el proceso, intentar restaurar la sesión original
          if (!mounted) return;
          try {
            await auth.signInWithEmailAndPassword(
              email: currentEmail,
              password: currentPassword,
            );
          } catch (loginError) {
            // Si no se puede restaurar la sesión, redirigir al login
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo restaurar la sesión. Por favor, inicie sesión nuevamente.'),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            return;
          }
          
          // Mostrar el error original
          if (!mounted) return;
          setState(() {
            _cargando = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al registrar administrador: $innerError'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Si no hay usuario actual, crear directamente
        final userCredential = await auth.createUserWithEmailAndPassword(
          email: _correoController.text,
          password: _contrasenaController.text,
        );
        
        await firestore.collection('administradores').doc(userCredential.user!.uid).set({
          'nombreAdm': _nombreController.text,
          'primerApellidoAdm': _primerApellidoController.text,
          'segundoApellidoAdm': _segundoApellidoController.text.isEmpty
              ? null
              : _segundoApellidoController.text,
          'celularAdm': _celularController.text,
          'correoAdm': _correoController.text,
        });
        
        if (!mounted) return;
        setState(() {
          _cargando = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Administrador registrado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        _limpiarFormulario();
        Navigator.pop(context);
      }
      
    } catch (e) {
      if (!mounted) return;
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
    _passwordActualController.dispose();
    super.dispose();
  }
}