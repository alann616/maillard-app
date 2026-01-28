import 'dart:async';
import 'package:app/core/database/app_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/inventory_repository.dart';

// Eventos
abstract class InventoryEvent extends Equatable {
  const InventoryEvent();
  @override
  List<Object> get props => [];
}
class SubscribeToInventory extends InventoryEvent {}
class _InventoryUpdated extends InventoryEvent {
  final List<Ingredient> ingredients;
  const _InventoryUpdated(this.ingredients);
}

// Estados
abstract class InventoryState extends Equatable {
  const InventoryState();
  @override
  List<Object> get props => [];
}
class InventoryLoading extends InventoryState {}
class InventoryLoaded extends InventoryState {
  final List<Ingredient> ingredients;
  const InventoryLoaded(this.ingredients);
  @override
  List<Object> get props => [ingredients];
}

// Bloc
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository _repository;
  StreamSubscription? _subscription;

  InventoryBloc(this._repository) : super(InventoryLoading()) {
    on<SubscribeToInventory>((event, emit) {
      _subscription?.cancel();
      _subscription = _repository.getInventoryStream().listen((items) {
        add(_InventoryUpdated(items));
      });
    });

    on<_InventoryUpdated>((event, emit) {
      emit(InventoryLoaded(event.ingredients));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}