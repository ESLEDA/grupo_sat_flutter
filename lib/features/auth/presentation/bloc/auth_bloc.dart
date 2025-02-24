import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/empleado.dart';
import '../../domain/entities/administrador.dart';
import '../../data/repositories/auth_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class RegisterEmpleadoRequested extends AuthEvent {
  final Empleado empleado;
  
  RegisterEmpleadoRequested(this.empleado);
  
  @override
  List<Object?> get props => [empleado];
}

class RegisterAdminRequested extends AuthEvent {
  final Administrador administrador;
  
  RegisterAdminRequested(this.administrador);
  
  @override
  List<Object?> get props => [administrador];
}

class CheckEmailExists extends AuthEvent {
  final String email;
  
  CheckEmailExists(this.email);
  
  @override
  List<Object?> get props => [email];
}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final String userType;
  AuthSuccess(this.userType);

  @override
  List<Object?> get props => [userType];
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
class EmailExistsState extends AuthState {
  final bool exists;
  EmailExistsState(this.exists);
  
  @override
  List<Object?> get props => [exists];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      
      try {
        final result = await _authRepository.loginUsuario(
          event.email, 
          event.password
        );
        
        emit(AuthSuccess(result['userType']));
      } catch (e) {
        emit(AuthError('Credenciales inválidas'));
      }
    });

    on<RegisterEmpleadoRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        // Verificar si el correo ya existe
        final exists = await _authRepository.emailExiste(event.empleado.correo);
        if (exists) {
          emit(AuthError('El correo ya está registrado'));
          return;
        }

        // Registrar empleado en Firebase
        await _authRepository.registerEmpleado(event.empleado);
        emit(AuthSuccess('empleado'));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
    
    on<RegisterAdminRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        // Verificar si el correo ya existe
        final exists = await _authRepository.emailExiste(event.administrador.correoAdm);
        if (exists) {
          emit(AuthError('El correo ya está registrado'));
          return;
        }

        // Registrar administrador en Firebase
        await _authRepository.registerAdministrador(event.administrador);
        emit(AuthSuccess('admin'));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
    
    on<CheckEmailExists>((event, emit) async {
      emit(AuthLoading());
      try {
        final exists = await _authRepository.emailExiste(event.email);
        emit(EmailExistsState(exists));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}