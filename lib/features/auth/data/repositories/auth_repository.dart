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
      // Guardar el usuario actual antes de registrar el nuevo empleado
      User? currentUser = _auth.currentUser;
      String? currentEmail;
      String? currentPassword;
      
      if (currentUser != null) {
        // No podemos obtener la contraseña directamente, por lo que debería proporcionarse
        // si necesitas volver a iniciar sesión con el usuario original
        currentEmail = currentUser.email;
      }

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

      // Si había un usuario previamente autenticado, volver a iniciar sesión con él
      if (currentEmail != null && currentPassword != null) {
        await _auth.signInWithEmailAndPassword(
          email: currentEmail,
          password: currentPassword,
        );
      }

      return userCredential;
    } catch (e) {
      throw Exception('Error en el registro de empleado: $e');
    }
  }

  // Registro de administrador sin cambiar el usuario actual
  Future<UserCredential> registerAdministrador(Administrador administrador) async {
    User? currentUser = _auth.currentUser;
    UserCredential? tempCredential;
    
    try {
      // Si hay un usuario actual, cerrar sesión temporalmente
      if (currentUser != null) {
        await _auth.signOut();
      }
      
      // Crear nuevo usuario en Authentication
      tempCredential = await _auth.createUserWithEmailAndPassword(
        email: administrador.correoAdm,
        password: administrador.contrasenaAdm,
      );

      // Guardar datos adicionales en Firestore
      await _firestore.collection('administradores').doc(tempCredential.user!.uid).set({
        'nombreAdm': administrador.nombreAdm,
        'primerApellidoAdm': administrador.primerApellidoAdm,
        'segundoApellidoAdm': administrador.segundoApellidoAdm,
        'celularAdm': administrador.celularAdm,
        'correoAdm': administrador.correoAdm,
      });

      // Almacenar las credenciales del nuevo administrador para devolver
      final newAdminCredential = tempCredential;
      
      // Si había un usuario previamente autenticado, volver a iniciar sesión con él
      if (currentUser != null) {
        // Como no podemos acceder a la contraseña original, necesitamos un enfoque alternativo
        // Una opción sería usar un token de autenticación temporal o una sesión persistente
        
        // Esta parte depende de cómo quieras manejar la reautenticación del usuario actual
        // Podrías modificar el flujo para pasar la contraseña del usuario actual como parámetro
        // o implementar un método de login silencioso con tokens
        
        // Por ahora, implementaremos un enfoque simple donde se necesita volver a iniciar sesión manualmente
        await _auth.signOut(); // Cerramos sesión del nuevo administrador
        
        // Aquí idealmente habría un relogin del usuario original, pero necesitamos su contraseña
        // Este método requeriría modificar la interfaz para solicitar la contraseña actual antes de crear un nuevo admin
      }

      return newAdminCredential;
    } catch (e) {
      // Si ocurre un error y teníamos un usuario previo, intentar restaurar su sesión
      if (currentUser != null) {
        // Intentar restaurar la sesión del usuario original (requiere gestión adicional)
      }
      throw Exception('Error en el registro de administrador: $e');
    }
  }

  // Versión alternativa del registro de administrador que no inicia sesión automáticamente
  Future<void> registerAdministradorSinLogin(Administrador administrador) async {
    try {
      // Crear una instancia secundaria de Firebase Auth
      // Nota: Esta es una solución conceptual, en la práctica Firebase no permite esto directamente
      // En un entorno real, deberías usar Firebase Admin SDK en el backend
      
      // Una solución práctica sería tener un endpoint en tu backend que maneje esto
      // Mientras tanto, una solución rudimentaria:
      
      // 1. Guardar el usuario actual
      User? currentUser = _auth.currentUser;
      
      // 2. Cerrar sesión temporalmente
      if (currentUser != null) {
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
      
      // 5. Volver a iniciar sesión con el usuario original
      // Aquí necesitaríamos las credenciales originales
      if (currentUser != null) {
        // Para una solución completa, necesitarías:
        // - O bien solicitar la contraseña del admin actual antes de esta operación
        // - O implementar tokens personalizados con Firebase Admin SDK en el backend
        
        // Por simplicidad, solo cerraremos sesión aquí y en la UI haríamos redirección
        await _auth.signOut();
      }
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