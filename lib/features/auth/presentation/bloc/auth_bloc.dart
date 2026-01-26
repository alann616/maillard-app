import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../features/pos/data/database/app_database.dart';
import '../../domain/repositories/auth_repository.dart';

// --- EVENTOS ---
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String pin;
  const LoginRequested(this.pin);
}

class LogoutRequested extends AuthEvent {}

// --- ESTADOS ---
enum AuthStatus { unknown, authenticated, unauthenticated, processing, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState._({required this.status, this.user, this.errorMessage});

  const AuthState.unknown() : this._(status: AuthStatus.unknown);
  const AuthState.unauthenticated({String? error}) : this._(status: AuthStatus.unauthenticated, errorMessage: error);
  const AuthState.authenticated(User user) : this._(status: AuthStatus.authenticated, user: user);
  const AuthState.processing() : this._(status: AuthStatus.processing);

  @override
  List<Object?> get props => [status, user, errorMessage];
}

// --- BLOC ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(const AuthState.unauthenticated()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>((event, emit) => emit(const AuthState.unauthenticated()));
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.processing());
    try {
      final user = await _repository.loginWithPin(event.pin);
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        emit(const AuthState.unauthenticated(error: "PIN Incorrecto"));
      }
    } catch (e) {
      emit(const AuthState.unauthenticated(error: "Error de sistema"));
    }
  }
}