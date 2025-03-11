import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/validators/auth_validators.dart';

class RecuperarContrasenaPage extends StatefulWidget {
  const RecuperarContrasenaPage({super.key});

  @override
  State<RecuperarContrasenaPage> createState() => _RecuperarContrasenaPageState();
}

class _RecuperarContrasenaPageState extends State<RecuperarContrasenaPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();
  final _nuevaContrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isProcessing = false;
  bool _codeSent = false;
  bool _verificacionExitosa = false;
  String _successMessage = '';
  String _errorMessage = '';
  String _verificationId = '';
  bool _mostrarNuevaContrasena = false;
  bool _mostrarConfirmarContrasena = false;

  Future<bool> _verificarCelularExisteEnFirestore(String celular) async {
    try {
      // Normalizar el número de teléfono (eliminar espacios y guiones)
      final celularNormalizado = celular.replaceAll(RegExp(r'[\s-]'), '');
      debugPrint('Verificando celular normalizado: $celularNormalizado');
      
      // Buscar en colección de empleados
      final QuerySnapshot empleadosSnapshot = await _firestore
          .collection('empleados')
          .get();
      
      // Verificar manualmente si existe el celular en empleados
      for (var doc in empleadosSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final celularEmpleado = data['celular']?.toString().replaceAll(RegExp(r'[\s-]'), '');
        debugPrint('Comparando con celular de empleado: $celularEmpleado');
        
        if (celularEmpleado == celularNormalizado) {
          debugPrint('Celular encontrado en empleados');
          return true;
        }
      }

      // Buscar en colección de administradores
      final QuerySnapshot adminsSnapshot = await _firestore
          .collection('administradores')
          .get();
          
      // Verificar manualmente si existe el celular en administradores
      for (var doc in adminsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final celularAdmin = data['celularAdm']?.toString().replaceAll(RegExp(r'[\s-]'), '');
        debugPrint('Comparando con celular de admin: $celularAdmin');
        
        if (celularAdmin == celularNormalizado) {
          debugPrint('Celular encontrado en administradores');
          return true;
        }
      }

      debugPrint('Celular no encontrado en ninguna colección');
      return false;
    } catch (e) {
      debugPrint('Error al verificar celular en Firestore: $e');
      return false;
    }
  }

  // Inicia el proceso de verificación por SMS
  Future<void> _enviarCodigoSMS() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = '';
      _successMessage = '';
    });

    final String celular = _phoneController.text.trim();
    
    try {
      // Verificar si el celular existe en Firestore
      final bool existeEnFirestore = await _verificarCelularExisteEnFirestore(celular);
      
      if (!existeEnFirestore) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'El número de celular no está registrado como empleado o administrador';
        });
        return;
      }
      
      // Formatear el número con el código de país (México: +52)
      final String phoneNumberFormatted = '+52$celular';
      
      // Enviar el código SMS
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumberFormatted,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Autoverificación en Android
          debugPrint('Verificación automática completada');
          await _manejarVerificacionCompletada(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Verificación fallida: ${e.message}');
          setState(() {
            _isProcessing = false;
            _errorMessage = 'Error al enviar SMS: ${e.message}';
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('Código SMS enviado');
          setState(() {
            _verificationId = verificationId;
            _isProcessing = false;
            _codeSent = true;
            _successMessage = 'Se ha enviado un código de verificación por SMS';
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('Tiempo de espera agotado');
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      debugPrint('Error inesperado: $e');
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error inesperado: $e';
      });
    }
  }
  
  // Maneja la verificación automática (principalmente en Android)
  Future<void> _manejarVerificacionCompletada(PhoneAuthCredential credential) async {
    try {
      // Intentar iniciar sesión con la credencial
      await _auth.signInWithCredential(credential);
      
      setState(() {
        _verificacionExitosa = true;
        _codeSent = true;
        _isProcessing = false;
        _successMessage = 'Verificación exitosa. Ahora puedes establecer tu nueva contraseña.';
      });
    } catch (e) {
      debugPrint('Error en verificación automática: $e');
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error en la verificación: $e';
      });
    }
  }

  // Verifica el código SMS ingresado manualmente
  Future<void> _verificarCodigoSMS() async {
    if (_smsCodeController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, ingresa el código de verificación';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = '';
    });

    try {
      // Crear credencial con el código ingresado
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _smsCodeController.text.trim(),
      );
      
      // Verificar credencial
      await _auth.signInWithCredential(credential);
      
      setState(() {
        _verificacionExitosa = true;
        _isProcessing = false;
        _successMessage = 'Verificación exitosa. Ahora puedes establecer tu nueva contraseña.';
      });
    } catch (e) {
      debugPrint('Error al verificar código SMS: $e');
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Código incorrecto o expirado. Inténtalo nuevamente.';
      });
    }
  }
  
  // Cambia la contraseña después de la verificación
  Future<void> _cambiarContrasena() async {
    if (_nuevaContrasenaController.text != _confirmarContrasenaController.text) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden';
      });
      return;
    }
    
    if (_nuevaContrasenaController.text.isEmpty || AuthValidators.validatePassword(_nuevaContrasenaController.text) != null) {
      setState(() {
        _errorMessage = 'La contraseña no cumple con los requisitos';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = '';
    });

    try {
      // El usuario ya está autenticado por teléfono, ahora actualizamos la contraseña
      final user = _auth.currentUser;
      
      if (user != null) {
        await user.updatePassword(_nuevaContrasenaController.text);
        
        setState(() {
          _isProcessing = false;
          _successMessage = 'Contraseña actualizada con éxito. Ya puedes iniciar sesión con tu nueva contraseña.';
        });
        
        // Cerrar sesión para que vuelva a iniciar con la nueva contraseña
        await _auth.signOut();
        
        // Redireccionar al login después de 3 segundos
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        });
      } else {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'No se pudo identificar la cuenta. Inténtalo de nuevo.';
        });
      }
    } catch (e) {
      debugPrint('Error al cambiar contraseña: $e');
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error al actualizar contraseña: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text("Recuperar Contraseña"),
        backgroundColor: const Color(0xFFF5F8FF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo e imagen
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/Logo-SAT.png',
                      height: 62,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Recuperación de contraseña',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF444957),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              
              // Etapa 1: Ingreso del número de celular
              if (!_codeSent)
                Column(
                  children: [
                    const Text(
                      'Ingresa tu número de celular registrado y te enviaremos un código por SMS para verificar tu identidad.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    
                    // Mostrar mensaje de error si existe
                    if (_errorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
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
                    
                    // Campo para el número de celular
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Número de celular (10 dígitos)',
                        hintText: 'Ejemplo: 5512345678',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18.0)),
                        ),
                        prefixIcon: Icon(Icons.phone_android),
                        prefixText: '+52 ',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: AuthValidators.validatePhone,
                    ),
                    const SizedBox(height: 24),
                    
                    // Botón para enviar SMS
                    _isProcessing
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _enviarCodigoSMS,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF193F6E),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                            child: const Text(
                              'Enviar código por SMS',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFF5F8FF),
                              ),
                            ),
                          ),
                  ],
                ),
              
              // Etapa 2: Verificación del código SMS
              if (_codeSent && !_verificacionExitosa)
                Column(
                  children: [
                    // Mostrar mensaje de éxito del envío de SMS
                    if (_successMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
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
                    
                    const SizedBox(height: 10),
                    const Text(
                      'Ingresa el código de verificación que enviamos a tu celular:',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    
                    // Mostrar mensaje de error si existe
                    if (_errorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
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
                    
                    // Campo para el código SMS
                    TextFormField(
                      controller: _smsCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Código de verificación',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18.0)),
                        ),
                        prefixIcon: Icon(Icons.sms),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    
                    // Botón para verificar código
                    _isProcessing
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _verificarCodigoSMS,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF193F6E),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                            child: const Text(
                              'Verificar código',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFF5F8FF),
                              ),
                            ),
                          ),
                    
                    // Botón para reenviar SMS
                    TextButton(
                      onPressed: _isProcessing 
                          ? null 
                          : () {
                              setState(() {
                                _codeSent = false;
                                _successMessage = '';
                              });
                            },
                      child: const Text(
                        'Cambiar número o reenviar código',
                        style: TextStyle(
                          color: Color(0xFF193F6E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              
              // Etapa 3: Cambio de contraseña
              if (_verificacionExitosa)
                Column(
                  children: [
                    // Mostrar mensaje de éxito de verificación
                    if (_successMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
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
                    
                    const SizedBox(height: 10),
                    const Text(
                      'Crea una nueva contraseña para tu cuenta:',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    
                    // Mostrar mensaje de error si existe
                    if (_errorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
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
                      
                    // Campo para nueva contraseña
                    TextFormField(
                      controller: _nuevaContrasenaController,
                      decoration: InputDecoration(
                        labelText: 'Nueva Contraseña',
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
                            _mostrarNuevaContrasena ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _mostrarNuevaContrasena = !_mostrarNuevaContrasena;
                            });
                          },
                        ),
                      ),
                      obscureText: !_mostrarNuevaContrasena,
                      validator: AuthValidators.validatePassword,
                    ),
                    
                    // Requisitos de contraseña
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
                    
                    // Campo para confirmar contraseña
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
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _mostrarConfirmarContrasena ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _mostrarConfirmarContrasena = !_mostrarConfirmarContrasena;
                            });
                          },
                        ),
                      ),
                      obscureText: !_mostrarConfirmarContrasena,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, confirma tu contraseña';
                        }
                        if (value != _nuevaContrasenaController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Botón para cambiar contraseña
                    _isProcessing
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _cambiarContrasena,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF193F6E),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                            child: const Text(
                              'Establecer nueva contraseña',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFF5F8FF),
                              ),
                            ),
                          ),
                  ],
                ),
                
              const SizedBox(height: 16),
              
              // Botón para volver al login (siempre visible)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Volver al inicio de sesión',
                  style: TextStyle(
                    color: Color(0xFF193F6E),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _smsCodeController.dispose();
    _nuevaContrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }
}