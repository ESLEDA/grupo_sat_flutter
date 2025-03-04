import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/material.dart';
import '../../data/repositories/material_repository.dart';

// Events
abstract class MaterialEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMateriales extends MaterialEvent {}

class AddMaterial extends MaterialEvent {
  final Material material;

  AddMaterial(this.material);

  @override
  List<Object?> get props => [material];
}

class UpdateMaterial extends MaterialEvent {
  final Material material;

  UpdateMaterial(this.material);

  @override
  List<Object?> get props => [material];
}

class DeleteMaterial extends MaterialEvent {
  final String materialId;

  DeleteMaterial(this.materialId);

  @override
  List<Object?> get props => [materialId];
}

// States
abstract class MaterialState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MaterialInitial extends MaterialState {}
class MaterialLoading extends MaterialState {}
class MaterialesLoaded extends MaterialState {
  final List<Material> materiales;

  MaterialesLoaded(this.materiales);

  @override
  List<Object?> get props => [materiales];
}
class MaterialOperationSuccess extends MaterialState {}
class MaterialOperationFailure extends MaterialState {
  final String message;

  MaterialOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class MaterialBloc extends Bloc<MaterialEvent, MaterialState> {
  final MaterialRepository _materialRepository;

  MaterialBloc(this._materialRepository) : super(MaterialInitial()) {
    on<LoadMateriales>((event, emit) async {
      emit(MaterialLoading());
      try {
        // Para usar el stream, convertimos a una lista en memoria
        final materiales = await _materialRepository.getMateriales().first;
        emit(MaterialesLoaded(materiales));
      } catch (e) {
        emit(MaterialOperationFailure('Error al cargar materiales: $e'));
      }
    });

    on<AddMaterial>((event, emit) async {
      emit(MaterialLoading());
      try {
        await _materialRepository.registrarMaterial(event.material);
        emit(MaterialOperationSuccess());
        add(LoadMateriales()); // Recargar la lista de materiales
      } catch (e) {
        emit(MaterialOperationFailure('Error al agregar material: $e'));
      }
    });

    on<UpdateMaterial>((event, emit) async {
      emit(MaterialLoading());
      try {
        await _materialRepository.actualizarMaterial(event.material);
        emit(MaterialOperationSuccess());
        add(LoadMateriales()); // Recargar la lista de materiales
      } catch (e) {
        emit(MaterialOperationFailure('Error al actualizar material: $e'));
      }
    });

    on<DeleteMaterial>((event, emit) async {
      emit(MaterialLoading());
      try {
        await _materialRepository.eliminarMaterial(event.materialId);
        emit(MaterialOperationSuccess());
        add(LoadMateriales()); // Recargar la lista de materiales
      } catch (e) {
        emit(MaterialOperationFailure('Error al eliminar material: $e'));
      }
    });
  }
}