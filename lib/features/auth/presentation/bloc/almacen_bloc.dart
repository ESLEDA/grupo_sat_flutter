import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/almacen.dart';
import '../../data/repositories/almacen_repository.dart';

// Events
abstract class AlmacenEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAlmacenes extends AlmacenEvent {}

class AddAlmacen extends AlmacenEvent {
  final Almacen almacen;

  AddAlmacen(this.almacen);

  @override
  List<Object?> get props => [almacen];
}

class UpdateAlmacen extends AlmacenEvent {
  final Almacen almacen;

  UpdateAlmacen(this.almacen);

  @override
  List<Object?> get props => [almacen];
}

class DeleteAlmacen extends AlmacenEvent {
  final String almacenId;

  DeleteAlmacen(this.almacenId);

  @override
  List<Object?> get props => [almacenId];
}

// States
abstract class AlmacenState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AlmacenInitial extends AlmacenState {}
class AlmacenLoading extends AlmacenState {}
class AlmacenesLoaded extends AlmacenState {
  final List<Almacen> almacenes;

  AlmacenesLoaded(this.almacenes);

  @override
  List<Object?> get props => [almacenes];
}
class AlmacenOperationSuccess extends AlmacenState {}
class AlmacenOperationFailure extends AlmacenState {
  final String message;

  AlmacenOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AlmacenBloc extends Bloc<AlmacenEvent, AlmacenState> {
  final AlmacenRepository _almacenRepository;

  AlmacenBloc(this._almacenRepository) : super(AlmacenInitial()) {
    on<LoadAlmacenes>((event, emit) async {
      emit(AlmacenLoading());
      try {
        // Para usar el stream, convertimos a una lista en memoria
        final almacenes = await _almacenRepository.getAlmacenes().first;
        emit(AlmacenesLoaded(almacenes));
      } catch (e) {
        emit(AlmacenOperationFailure('Error al cargar almacenes: $e'));
      }
    });

    on<AddAlmacen>((event, emit) async {
      emit(AlmacenLoading());
      try {
        await _almacenRepository.registrarAlmacen(event.almacen);
        emit(AlmacenOperationSuccess());
        add(LoadAlmacenes()); // Recargar la lista de almacenes
      } catch (e) {
        emit(AlmacenOperationFailure('Error al agregar almacén: $e'));
      }
    });

    on<UpdateAlmacen>((event, emit) async {
      emit(AlmacenLoading());
      try {
        await _almacenRepository.actualizarAlmacen(event.almacen);
        emit(AlmacenOperationSuccess());
        add(LoadAlmacenes()); // Recargar la lista de almacenes
      } catch (e) {
        emit(AlmacenOperationFailure('Error al actualizar almacén: $e'));
      }
    });

    on<DeleteAlmacen>((event, emit) async {
      emit(AlmacenLoading());
      try {
        await _almacenRepository.eliminarAlmacen(event.almacenId);
        emit(AlmacenOperationSuccess());
        add(LoadAlmacenes()); // Recargar la lista de almacenes
      } catch (e) {
        emit(AlmacenOperationFailure('Error al eliminar almacén: $e'));
      }
    });
  }
}