import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/database/app_database.dart';

// Eventos
abstract class TableEvent extends Equatable {
  const TableEvent();
  @override
  List<Object> get props => [];
}
class SubscribeToTables extends TableEvent {}
class _TablesUpdated extends TableEvent {
  final List<TableWithStatus> tables;
  const _TablesUpdated(this.tables);
}

// Estados
abstract class TableState extends Equatable {
  const TableState();
  @override
  List<Object> get props => [];
}
class TableLoading extends TableState {}
class TableLoaded extends TableState {
  final List<TableWithStatus> tables;
  const TableLoaded(this.tables);
  @override
  List<Object> get props => [tables];
}
class TableError extends TableState {
  final String message;
  const TableError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class TableBloc extends Bloc<TableEvent, TableState> {
  final AppDatabase _db;
  StreamSubscription? _subscription;

  TableBloc(this._db) : super(TableLoading()) {
    on<SubscribeToTables>((event, emit) {
      _subscription?.cancel();
      // Escuchamos el stream de mesas vivas
      _subscription = _db.watchTables().listen(
        (data) => add(_TablesUpdated(data)),
        onError: (e) => emit(TableError(e.toString())),
      );
    });

    on<_TablesUpdated>((event, emit) {
      emit(TableLoaded(event.tables));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}