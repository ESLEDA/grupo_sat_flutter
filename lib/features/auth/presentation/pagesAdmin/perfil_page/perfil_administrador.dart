import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/validators/auth_validators.dart';

class PerfilAdministradorPage extends StatefulWidget {
  const PerfilAdministradorPage({super.key});

  @override
  State<PerfilAdministradorPage> createState() => _PerfilAdministradorPageState();
}

class _PerfilAdministradorPageState extends State<PerfilAdministradorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _primerApellidoController = TextEditingController();
  final _segundoApellidoController = TextEditingController();
  final _celularController = TextEditingController();
  final _correoController = TextEditingController();
  final _nuevaContrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();
  final _contrasenaActualController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = true;
  bool _isSaving = false;
  bool _mostrarNuevaContrasena = false;
  bool _mostrarConfirmarContrasena = false;
  bool _mostrarContrasenaActual = false;
  bool _requiereReautenticacion = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosPerfil();
  }

  Future<void> _cargarDatosPerfil() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Obtener el usuario actual autenticado
      final User? user = _auth.currentUser;
      if (user != null) {
        // Obtener datos del administrador desde Firestore
        final adminDoc = await _firestore
            .collection('administradores')
            .doc(user.uid)
            .get();

        if (adminDoc.exists) {
          // Cargar datos en los controladores
          _nombreController.text = adminDoc.data()?['nombreAdm'] ?? '';
          _primerApellidoController.text = adminDoc.data()?['primerApellidoAdm'] ?? '';
          _segundoApellidoController.text = adminDoc.data()?['segundoApellidoAdm'] ?? '';
          _celularController.text = adminDoc.data()?['celularAdm'] ?? '';
          _correoController.text = adminDoc.data()?['correoAdm'] ?? '';
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Método para solicitar la contraseña actual para reautenticación
  Future<bool> _solicitarContrasenaActual() async {
    _contrasenaActualController.clear();
    
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Confirmar contraseña'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Para actualizar tu información, por favor confirma tu contraseña actual.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contrasenaActualController,
                    obscureText: !_mostrarContrasenaActual,
                    decoration: InputDecoration(
                      labelText: 'Contraseña actual',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _mostrarContrasenaActual ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            _mostrarContrasenaActual = !_mostrarContrasenaActual;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          }
        );
      },
    ) ?? false;
  }

  Future<void> _reautenticarUsuario() async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.email != null) {
        // Crear credenciales con el email actual y la contraseña proporcionada
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _contrasenaActualController.text,
        );
        
        // Reautenticar al usuario
        await user.reauthenticateWithCredential(credential);
        
        // Si llegamos aquí, la reautenticación fue exitosa
        setState(() {
          _requiereReautenticacion = false;
        });
        
        return;
      }
    } catch (e) {
      // Mostrar error de reautenticación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña actual es incorrecta. Por favor intente nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
      
      // Mantener la bandera de reautenticación requerida
      setState(() {
        _requiereReautenticacion = true;
      });
      
      // Lanzar excepción para que el método que llama sepa que falló
      throw Exception('Reautenticación fallida');
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        // Verificar si se requiere una acción que necesita reautenticación
        final bool correoModificado = user.email != _correoController.text;
        final bool cambiaContrasena = _nuevaContrasenaController.text.isNotEmpty;
        
        // Si se cambia correo o contraseña, verificar si necesitamos reautenticar
        if ((correoModificado || cambiaContrasena) && _requiereReautenticacion == false) {
          try {
            // Intentar operación sensible para ver si requiere reautenticación
            if (cambiaContrasena) {
              await user.updatePassword(_nuevaContrasenaController.text);
            } else if (correoModificado) {
              await user.updateEmail(_correoController.text);
            }
          } catch (e) {
            // Si obtenemos un error de reautenticación requerida
            if (e is FirebaseAuthException && 
                (e.code == 'requires-recent-login' || e.code == 'user-token-expired')) {
              setState(() {
                _requiereReautenticacion = true;
              });
              
              // Solicitar contraseña actual
              final continuar = await _solicitarContrasenaActual();
              if (!continuar) {
                setState(() {
                  _isSaving = false;
                });
                return;
              }
              
              // Reautenticar al usuario
              await _reautenticarUsuario();
            } else {
              throw e; // Otro tipo de error, relanzar
            }
          }
        } else if (_requiereReautenticacion) {
          // Si ya sabemos que se requiere reautenticación
          final continuar = await _solicitarContrasenaActual();
          if (!continuar) {
            setState(() {
              _isSaving = false;
            });
            return;
          }
          
          // Reautenticar al usuario
          await _reautenticarUsuario();
        }
        
        // Actualizar datos en Firestore
        await _firestore.collection('administradores').doc(user.uid).update({
          'nombreAdm': _nombreController.text,
          'primerApellidoAdm': _primerApellidoController.text,
          'segundoApellidoAdm': _segundoApellidoController.text.isEmpty
              ? null
              : _segundoApellidoController.text,
          'celularAdm': _celularController.text,
          'correoAdm': _correoController.text,
        });
           
        // Si el correo electrónico ha cambiado, actualizarlo en Auth
        if (correoModificado) {
          await user.updateEmail(_correoController.text);
        }
        
        // Si el usuario ingresó una nueva contraseña, actualizarla
        if (cambiaContrasena) {
          await user.updatePassword(_nuevaContrasenaController.text);
          // Limpiar los campos de contraseña después de actualizar
          _nuevaContrasenaController.clear();
          _confirmarContrasenaController.clear();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFFF5F8FF),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Imagen de perfil (avatar)
                    const Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFF193F6E),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Campos del formulario
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
                    const SizedBox(height: 24),
                    
                    // Sección de cambio de contraseña
                    const Text(
                      'Cambiar Contraseña (opcional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
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
                      validator: (value) {
                        // Validar solo si hay algo escrito, ya que es opcional
                        if (value == null || value.isEmpty) {
                          return null; // No requiere validación si está vacío
                        }
                        return AuthValidators.validatePassword(value);
                      },
                      onChanged: (value) {
                        // Forzar actualización de UI para mostrar/ocultar requisitos
                        setState(() {});
                      },
                    ),
                    
                    // Mostrar requisitos de contraseña si hay texto
                    Visibility(
                      visible: _nuevaContrasenaController.text.isNotEmpty,
                      child: Container(
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
                    ),
                    const SizedBox(height: 16),
                    
                    // Campo para confirmar contraseña (visible solo si se está cambiando)
                    Visibility(
                      visible: _nuevaContrasenaController.text.isNotEmpty,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _confirmarContrasenaController,
                            decoration: InputDecoration(
                              labelText: 'Confirmar Nueva Contraseña',
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
                              if (_nuevaContrasenaController.text.isEmpty) {
                                return null; // No validar si no hay nueva contraseña
                              }
                              if (value == null || value.isEmpty) {
                                return 'Debe confirmar la nueva contraseña';
                              }
                              if (value != _nuevaContrasenaController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    
                    // Botón de guardar cambios
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _guardarCambios,
                      icon: _isSaving 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: const Text('Guardar Cambios'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF193F6E),
                        foregroundColor: const Color(0xFFF5F8FF),
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

  @override
  void dispose() {
    _nombreController.dispose();
    _primerApellidoController.dispose();
    _segundoApellidoController.dispose();
    _celularController.dispose();
    _correoController.dispose();
    _nuevaContrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    _contrasenaActualController.dispose();
    super.dispose();
  }
}