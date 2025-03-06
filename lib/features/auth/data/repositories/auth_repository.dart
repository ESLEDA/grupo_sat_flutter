import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/empleado.dart';
import '../../domain/entities/administrador.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registro de empleado - Versión mejorada
  Future<UserCredential> registerEmpleado(Empleado empleado) async {
    try {
      print("Iniciando registro de empleado con email: ${empleado.correo}");
      
      // Crear usuario en Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: empleado.correo,
        password: empleado.contrasena,
      );
      
      print("Usuario creado en Authentication con UID: ${userCredential.user!.uid}");

      // Guardar datos adicionales en Firestore
      await _firestore.collection('empleados').doc(userCredential.user!.uid).set({
        'nombreEmpleado': empleado.nombreEmpleado,
        'primerApellido': empleado.primerApellido,
        'segundoApellido': empleado.segundoApellido,
        'celular': empleado.celular,
        'correo': empleado.correo,
        // No almacenamos la contraseña por seguridad
      });
      
      print("Datos de empleado guardados en Firestore");
      return userCredential;
    } catch (e) {
      print("Error en el registro de empleado: $e");
      throw Exception('Error en el registro de empleado: $e');
    }
  }

  // Registro de administrador - Versión mejorada
  Future<UserCredential> registerAdministrador(Administrador administrador) async {
    try {
      print("Iniciando registro de administrador con email: ${administrador.correoAdm}");
      
      // Crear nuevo usuario en Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: administrador.correoAdm,
        password: administrador.contrasenaAdm,
      );
      
      print("Administrador creado en Authentication con UID: ${userCredential.user!.uid}");

      // Guardar datos adicionales en Firestore
      await _firestore.collection('administradores').doc(userCredential.user!.uid).set({
        'nombreAdm': administrador.nombreAdm,
        'primerApellidoAdm': administrador.primerApellidoAdm,
        'segundoApellidoAdm': administrador.segundoApellidoAdm,
        'celularAdm': administrador.celularAdm,
        'correoAdm': administrador.correoAdm,
        // No almacenamos la contraseña por seguridad
      });
      
      print("Datos de administrador guardados en Firestore");
      return userCredential;
    } catch (e) {
      print("Error en el registro de administrador: $e");
      throw Exception('Error en el registro de administrador: $e');
    }
  }

  // Versión alternativa del registro de administrador sin inicio de sesión
  Future<void> registerAdministradorSinLogin(Administrador administrador) async {
    try {
      // 1. Guardar el usuario actual
      User? currentUser = _auth.currentUser;
      
      // 2. Cerrar sesión temporalmente
      if (currentUser != null) {
        print("Cerrando sesión de usuario actual para crear administrador");
        await _auth.signOut();
      }
      
      // 3. Crear el nuevo administrador
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: administrador.correoAdm,
        password: administrador.contrasenaAdm,
      );
      
      // 4. Guardar datos en Firestore
      await _firestore.collection('administradores').doc(userCredential.user!.uid).set({
        'nombreAdm': administrador.nombreAdm,
        'primerApellidoAdm': administrador.primerApellidoAdm,
        'segundoApellidoAdm': administrador.segundoApellidoAdm,
        'celularAdm': administrador.celularAdm,
        'correoAdm': administrador.correoAdm,
      });
      
      print("Administrador creado correctamente");
      
      // 5. Cerrar sesión del nuevo administrador
      await _auth.signOut();
      print("Sesión cerrada del nuevo administrador");
    } catch (e) {
      print("Error en el registro de administrador sin login: $e");
      throw Exception('Error en el registro de administrador: $e');
    }
  }

  // Login para cualquier usuario - Mejorado con más logging
  Future<Map<String, dynamic>> loginUsuario(String email, String password) async {
    try {
      print("Intentando iniciar sesión con: $email");
      
      // Autenticar usuario con Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print("Usuario autenticado con UID: ${userCredential.user!.uid}");
      
      // Verificar si es un administrador
      final adminDoc = await _firestore
          .collection('administradores')
          .doc(userCredential.user!.uid)
          .get();
      
      if (adminDoc.exists) {
        print("Es un administrador");
        return {
          'userCredential': userCredential,
          'userType': 'admin'
        };
      }
      
      // Verificar si es un empleado
      final empleadoDoc = await _firestore
          .collection('empleados')
          .doc(userCredential.user!.uid)
          .get();
      
      if (empleadoDoc.exists) {
        print("Es un empleado");
        return {
          'userCredential': userCredential,
          'userType': 'empleado'
        };
      }
      
      print("Usuario no encontrado en la base de datos de empleados o administradores");
      // Si no está en ninguna colección, cerrar sesión
      await _auth.signOut();
      throw Exception('Usuario no encontrado en la base de datos');
      
    } catch (e) {
      print("Error en el login: $e");
      throw Exception('Error en el login: $e');
    }
  }
  
  // Verificar si existe un email en Firebase Auth
  Future<bool> emailExiste(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      print("Métodos de inicio de sesión para $email: $methods");
      return methods.isNotEmpty;
    } catch (e) {
      print("Error al verificar si existe el email: $e");
      return false;
    }
  }
  
  // Método para depurar y verificar el estado actual
  Future<Map<String, dynamic>> verificarUsuarioActual() async {
    try {
      final User? currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        return {
          'loggedIn': false,
          'message': 'No hay usuario con sesión activa'
        };
      }
      
      // Comprobar si es administrador
      final adminDoc = await _firestore
          .collection('administradores')
          .doc(currentUser.uid)
          .get();
          
      if (adminDoc.exists) {
        return {
          'loggedIn': true,
          'userType': 'admin',
          'uid': currentUser.uid,
          'email': currentUser.email,
          'userData': adminDoc.data()
        };
      }
      
      // Comprobar si es empleado
      final empleadoDoc = await _firestore
          .collection('empleados')
          .doc(currentUser.uid)
          .get();
          
      if (empleadoDoc.exists) {
        return {
          'loggedIn': true,
          'userType': 'empleado',
          'uid': currentUser.uid,
          'email': currentUser.email,
          'userData': empleadoDoc.data()
        };
      }
      
      return {
        'loggedIn': true,
        'userType': 'unknown',
        'uid': currentUser.uid,
        'email': currentUser.email,
        'message': 'Usuario autenticado pero no encontrado en Firestore'
      };
    } catch (e) {
      return {
        'loggedIn': false,
        'error': e.toString()
      };
    }
  }
  
  // Método para cerrar sesión
  Future<void> cerrarSesion() async {
    try {
      await _auth.signOut();
      print("Sesión cerrada correctamente");
    } catch (e) {
      print("Error al cerrar sesión: $e");
      throw Exception('Error al cerrar sesión: $e');
    }
  }
}