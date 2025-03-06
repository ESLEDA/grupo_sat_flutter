import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecuperarContrasenaPage extends StatefulWidget {
  const RecuperarContrasenaPage({super.key});

  @override
  State<RecuperarContrasenaPage> createState() => _RecuperarContrasenaPageState();
}

class _RecuperarContrasenaPageState extends State<RecuperarContrasenaPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isVerifying = false;
  String _errorMessage = '';
  String _successMessage = '';

  // Método para verificar si el correo existe en Firebase
  Future<bool> _verificarCorreoExistente(String email) async {
    try {
      // Verificar en colección de empleados
      final QuerySnapshot empleadoSnapshot = await FirebaseFirestore.instance
          .collection('empleados')
          .where('correo', isEqualTo: email)
          .get();

      // Verificar en colección de administradores
      final QuerySnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection('administradores')
          .where('correoAdm', isEqualTo: email)
          .get();

      // El correo existe si se encuentra en alguna de las colecciones
      return empleadoSnapshot.docs.isNotEmpty || adminSnapshot.docs.isNotEmpty;
    } catch (e) {
      // En caso de error, retornar false
      debugPrint('Error al verificar correo: $e');
      return false;
    }
  }

  // Método para enviar el correo de recuperación
  Future<void> _enviarCorreoRecuperacion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final email = _emailController.text.trim();
      
      // Primero verificamos si el correo existe en Firestore
      bool correoExiste = await _verificarCorreoExistente(email);

      if (!correoExiste) {
        setState(() {
          _isVerifying = false;
          _errorMessage = 'Correo no registrado';
        });
        return;
      }

      // Si el correo existe, enviamos el correo de recuperación
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      setState(() {
        _isVerifying = false;
        _successMessage = 'Se ha enviado un correo de recuperación a $email';
      });
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Error al enviar correo: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8FF),
        title: const Text('Recuperar Contraseña'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: Color(0xFF193F6E),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Recuperación de Contraseña',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF193F6E),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ingresa tu correo electrónico registrado y te enviaremos un enlace para recuperar tu contraseña.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Campo de correo electrónico
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu correo electrónico';
                    }
                    
                    // Validación básica de formato de correo
                    final emailRegExp = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    );
                    if (!emailRegExp.hasMatch(value)) {
                      return 'Ingresa un correo válido';
                    }
                    
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Mensaje de error si existe
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red.shade800),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                // Mensaje de éxito si existe
                if (_successMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Text(
                      _successMessage,
                      style: TextStyle(color: Colors.green.shade800),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Botón de enviar
                _isVerifying
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _enviarCorreoRecuperacion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF193F6E),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                        child: const Text(
                          'Enviar Correo de Recuperación',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFF5F8FF),
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Volver al inicio de sesión',
                    style: TextStyle(
                      color: Color(0xFF193F6E),
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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}