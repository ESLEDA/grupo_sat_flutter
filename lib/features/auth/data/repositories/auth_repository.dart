import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/empleado.dart';
import '../../domain/entities/administrador.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registro de empleado
  Future<UserCredential> registerEmpleado(Empleado empleado) async {
    try {
      // Crear usuario en Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: empleado.correo,
        password: empleado.contrasena,
      );

      // Guardar datos adicionales en Firestore
      await _firestore.collection('empleados').doc(userCredential.user!.uid).set({
        'nombreEmpleado': empleado.nombreEmpleado,
        'primerApellido': empleado.primerApellido,
        'segundoApellido': empleado.segundoApellido,
        'celular': empleado.celular,
        'correo': empleado.correo,
      });

      return userCredential;
    } catch (e) {
      throw Exception('Error en el registro de empleado: $e');
    }
  }

  // Registro de administrador
  Future<UserCredential> registerAdministrador(Administrador administrador) async {
    try {
      // Crear usuario en Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: administrador.correoAdm,
        password: administrador.contrasenaAdm,
      );

      // Guardar datos adicionales en Firestore
      await _firestore.collection('administradores').doc(userCredential.user!.uid).set({
        'nombreAdm': administrador.nombreAdm,
        'primerApellidoAdm': administrador.primerApellidoAdm,
        'segundoApellidoAdm': administrador.segundoApellidoAdm,
        'celularAdm': administrador.celularAdm,
        'correoAdm': administrador.correoAdm,
      });

      return userCredential;
    } catch (e) {
      throw Exception('Error en el registro de administrador: $e');
    }
  }

  // Login para cualquier usuario
  Future<Map<String, dynamic>> loginUsuario(String email, String password) async {
    try {
      // Autenticar usuario con Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Verificar si es un administrador
      final adminDoc = await _firestore
          .collection('administradores')
          .doc(userCredential.user!.uid)
          .get();
      
      if (adminDoc.exists) {
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
        return {
          'userCredential': userCredential,
          'userType': 'empleado'
        };
      }
      
      // Si no está en ninguna colección, cerrar sesión
      await _auth.signOut();
      throw Exception('Usuario no encontrado en la base de datos');
      
    } catch (e) {
      throw Exception('Error en el login: $e');
    }
  }
  
  // Verificar si existe un email en Firebase Auth
  Future<bool> emailExiste(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}