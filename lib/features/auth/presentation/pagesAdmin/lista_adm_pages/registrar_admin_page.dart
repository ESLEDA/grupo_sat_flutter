import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _mostrarContrasena = false; // Para controlar la visibilidad de la contraseña
  bool _mostrarConfirmarContrasena = false; // Para controlar la visibilidad de la confirmación

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: CustomScrollView(
        slivers: [
          // AppBar exactamente igual al de RegistroPage
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFF5F8FF),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'Registrar Nuevo Administrador',
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
          
          // Contenido del formulario
          SliverPadding(
            padding: const EdgeInsets.all(14.0),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                        prefixIcon: Icon(Icons.person_outline, color: Color(0xFF193F6E)),
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
                        prefixIcon: Icon(Icons.phone, color: Color(0xFF193F6E)),
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
                        prefixIcon: Icon(Icons.email, color: Color(0xFF193F6E)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: AuthValidators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    
                    // Contraseña con toggle de visibilidad
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
                            _mostrarContrasena ? Icons.visibility : Icons.visibility_off,
                            color: const Color(0xFF193F6E),
                          ),
                          onPressed: () {
                            setState(() {
                              _mostrarContrasena = !_mostrarContrasena;
                            });
                          },
                          tooltip: _mostrarContrasena ? 'Ocultar contraseña' : 'Mostrar contraseña',
                        ),
                      ),
                      obscureText: !_mostrarContrasena,
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
                    
                    // Confirmar Contraseña con toggle de visibilidad
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
                            _mostrarConfirmarContrasena ? Icons.visibility : Icons.visibility_off,
                            color: const Color(0xFF193F6E),
                          ),
                          onPressed: () {
                            setState(() {
                              _mostrarConfirmarContrasena = !_mostrarConfirmarContrasena;
                            });
                          },
                          tooltip: _mostrarConfirmarContrasena ? 'Ocultar contraseña' : 'Mostrar contraseña',
                        ),
                      ),
                      obscureText: !_mostrarConfirmarContrasena,
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
                    const SizedBox(height: 24), // Espacio adicional al final para mejor scroll
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método para solicitar la contraseña actual para reautenticación
  Future<String?> _solicitarContrasenaActual() async {
    _passwordActualController.clear();
    bool _mostrarPasswordActual = false;
    
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                    obscureText: !_mostrarPasswordActual,
                    decoration: InputDecoration(
                      labelText: 'Contraseña actual',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _mostrarPasswordActual ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _mostrarPasswordActual = !_mostrarPasswordActual;
                          });
                        },
                      ),
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
          }
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