import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/marca.dart';
import '../../data/repositories/marca_repository.dart';

// Events
abstract class MarcaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMarcas extends MarcaEvent {}

class AddMarca extends MarcaEvent {
  final Marca marca;

  AddMarca(this.marca);

  @override
  List<Object?> get props => [marca];
}

class UpdateMarca extends MarcaEvent {
  final Marca marca;

  UpdateMarca(this.marca);

  @override
  List<Object?> get props => [marca];
}

class DeleteMarca extends MarcaEvent {
  final String marcaId;

  DeleteMarca(this.marcaId);

  @override
  List<Object?> get props => [marcaId];
}

// States
abstract class MarcaState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MarcaInitial extends MarcaState {}
class MarcaLoading extends MarcaState {}
class MarcasLoaded extends MarcaState {
  final List<Marca> marcas;

  MarcasLoaded(this.marcas);

  @override
  List<Object?> get props => [marcas];
}
class MarcaOperationSuccess extends MarcaState {}
class MarcaOperationFailure extends MarcaState {
  final String message;

  MarcaOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class MarcaBloc extends Bloc<MarcaEvent, MarcaState> {
  final MarcaRepository _marcaRepository;

  MarcaBloc(this._marcaRepository) : super(MarcaInitial()) {
    on<LoadMarcas>((event, emit) async {
      emit(MarcaLoading());
      try {
        // Para usar el stream, convertimos a una lista en memoria
        final marcas = await _marcaRepository.getMarcas().first;
        emit(MarcasLoaded(marcas));
      } catch (e) {
        emit(MarcaOperationFailure('Error al cargar marcas: $e'));
      }
    });

    on<AddMarca>((event, emit) async {
      emit(MarcaLoading());
      try {
        await _marcaRepository.registrarMarca(event.marca);
        emit(MarcaOperationSuccess());
        add(LoadMarcas()); // Recargar la lista de marcas
      } catch (e) {
        emit(MarcaOperationFailure('Error al agregar marca: $e'));
      }
    });

    on<UpdateMarca>((event, emit) async {
      emit(MarcaLoading());
      try {
        await _marcaRepository.actualizarMarca(event.marca);
        emit(MarcaOperationSuccess());
        add(LoadMarcas()); // Recargar la lista de marcas
      } catch (e) {
        emit(MarcaOperationFailure('Error al actualizar marca: $e'));
      }
    });

    on<DeleteMarca>((event, emit) async {
      emit(MarcaLoading());
      try {
        await _marcaRepository.eliminarMarca(event.marcaId);
        emit(MarcaOperationSuccess());
        add(LoadMarcas()); // Recargar la lista de marcas
      } catch (e) {
        emit(MarcaOperationFailure('Error al eliminar marca: $e'));
      }
    });
  }
}