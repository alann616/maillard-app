import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:app/core/database/app_database.dart';
import 'package:app/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:app/features/inventory/data/database/inventory_transactions.dart';

// -----------------------------------------------------------------------------
// 🏗️ EVENTS (Órdenes de la UI)
// -----------------------------------------------------------------------------
abstract class InventoryEvent extends Equatable {
  const InventoryEvent();
  @override
  List<Object> get props => [];
}

/// Iniciar la escucha en tiempo real del inventario
class SubscribeToInventory extends InventoryEvent {}

/// Ajuste rápido de stock (+/-)
class UpdateStock extends InventoryEvent {
  final int ingredientId;
  final double quantity;
  
  const UpdateStock(this.ingredientId, this.quantity);
}

/// Crear un nuevo insumo
class CreateIngredientEvent extends InventoryEvent {
  final String name;
  final String unit;
  final double cost;
  final double minStock;
  final double initialStock;

  const CreateIngredientEvent({
    required this.name, 
    required this.unit, 
    required this.cost, 
    required this.minStock,
    this.initialStock = 0.0,
  });
}

/// Editar datos de un insumo existente
class EditIngredientEvent extends InventoryEvent {
  final Ingredient ingredient;
  const EditIngredientEvent(this.ingredient);
}

/// Eliminar un insumo
class DeleteIngredientEvent extends InventoryEvent {
  final int id;
  const DeleteIngredientEvent(this.id);
}

// -----------------------------------------------------------------------------
// 📊 STATES (Estados de la Pantalla)
// -----------------------------------------------------------------------------
abstract class InventoryState extends Equatable {
  const InventoryState();
  @override
  List<Object> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<Ingredient> ingredients;
  const InventoryLoaded(this.ingredients);

  @override
  List<Object> get props => [ingredients];
}

class InventoryError extends InventoryState {
  final String message;
  const InventoryError(this.message);
  
  @override
  List<Object> get props => [message];
}

// -----------------------------------------------------------------------------
// 🧠 BLOC (Lógica de Negocio)
// -----------------------------------------------------------------------------
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository _repository;

  InventoryBloc(this._repository) : super(InventoryInitial()) {
    
    // 1. Suscripción al Stream (Tiempo Real)
    on<SubscribeToInventory>((event, emit) async {
      emit(InventoryLoading());
      await emit.forEach(
        _repository.getInventoryStream(),
        onData: (List<Ingredient> data) => InventoryLoaded(data),
        onError: (error, stackTrace) => InventoryError(error.toString()),
      );
    });

    // 2. Ajuste de Stock
    on<UpdateStock>((event, emit) async {
      try {
        await _repository.adjustStock(
          event.ingredientId, 
          event.quantity, 
          TransactionType.adjustment
        );
        // No emitimos estado nuevo porque el Stream de arriba se actualiza solo
      } catch (e) {
        debugPrint("Error actualizando stock: $e");
      }
    });

    // 3. Crear Insumo
    on<CreateIngredientEvent>((event, emit) async {
      try {
        await _repository.createIngredient(
          event.name, event.unit, event.cost, event.minStock, event.initialStock
        );
      } catch (e) {
        // En caso de error, podríamos emitir un estado de error temporal,
        // pero por ahora solo logueamos para no romper el Stream de la lista.
        debugPrint("Error creando insumo: $e");
      }
    });

    // 4. Editar Insumo
    on<EditIngredientEvent>((event, emit) async {
      try {
        await _repository.updateIngredient(event.ingredient);
      } catch (e) {
        debugPrint("Error editando insumo: $e");
      }
    });

    // 5. Eliminar Insumo
    on<DeleteIngredientEvent>((event, emit) async {
      try {
        await _repository.deleteIngredient(event.id);
      } catch (e) {
        debugPrint("Error eliminando insumo: $e");
      }
    });
  }
}
