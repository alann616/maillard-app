import 'package:app/core/database/app_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // P
import '../../domain/repositories/inventory_repository.dart';
// IMPORTANTE: Importar el archivo de transacciones para usar TransactionType
import '../../data/database/inventory_transactions.dart';

// --- EVENTS ---
abstract class InventoryEvent extends Equatable {
  const InventoryEvent();
  @override
  List<Object> get props => [];
}

class SubscribeToInventory extends InventoryEvent {}

class UpdateStock extends InventoryEvent {
  final int ingredientId;
  final double quantity;
  
  const UpdateStock(this.ingredientId, this.quantity);
}

// --- STATES ---
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
}

// --- BLOC ---
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository _repository;

  InventoryBloc(this._repository) : super(InventoryInitial()) {
    
    on<SubscribeToInventory>((event, emit) async {
      emit(InventoryLoading());
      await emit.forEach(
        _repository.getInventoryStream(),
        onData: (List<Ingredient> data) => InventoryLoaded(data),
        onError: (error, stackTrace) => InventoryError(error.toString()),
      );
    });

    on<UpdateStock>((event, emit) async {
      try {
        // CORRECCIÓN AQUÍ: Usamos adjustStock en lugar de addStock
        // Asumimos TransactionType.adjustment porque viene de un botón rápido de +/-
        await _repository.adjustStock(
          event.ingredientId, 
          event.quantity, 
          TransactionType.adjustment
        );
      } catch (e) {
        debugPrint("Error actualizando stock: $e");
        // Opcional: emitir un error temporal o usar un Listener en la UI
      }
    });
  }
}