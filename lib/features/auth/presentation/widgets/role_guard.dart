import 'package:app/features/pos/domain/models/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';

class RoleGuard extends StatelessWidget {
  final Widget child;
  final List<UserRole> allowedRoles;

  const RoleGuard({
    super.key,
    required this.child,
    required this.allowedRoles, // ¿Quién tiene permiso de ver esto?
  });

  @override
  Widget build(BuildContext context) {
    // Escuchamos el estado del AuthBloc
    // Usamos watch para que si el usuario cambia (logout), esto se actualice
    final state = context.watch<AuthBloc>().state;

    // 1. Si no hay usuario logueado, ocultamos.
    if (state.user == null) {
      return const SizedBox.shrink();
    }

    // 2. Si el rol del usuario está en la lista permitida, mostramos el widget.
    if (allowedRoles.contains(state.user!.role)) {
      return child;
    }

    // 3. Si no tiene permiso, retornamos una caja vacía (invisible).
    return const SizedBox.shrink();
  }
}