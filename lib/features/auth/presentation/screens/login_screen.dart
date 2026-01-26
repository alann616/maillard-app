import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _pin = "";

  void _onNumberPress(String number) {
    if (_pin.length < 4) {
      setState(() => _pin += number);
    }
    if (_pin.length == 4) {
      // Disparamos el evento de login automáticamente al tener 4 dígitos
      context.read<AuthBloc>().add(LoginRequested(_pin));
      // Limpiamos el PIN visualmente (opcional, por seguridad)
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _pin = "");
      });
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          // Si el login es exitoso, nos vamos a las mesas
          context.go('/'); 
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: AppTheme.error),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.primary,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(blurRadius: 20, color: Colors.black45)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 60, color: AppTheme.primary),
                const SizedBox(height: 20),
                const Text("Ingrese PIN", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                // Puntos del PIN
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < _pin.length ? AppTheme.accent : Colors.grey.shade300,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 30),
                // Teclado Numérico
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  children: [
                    for (var i = 1; i <= 9; i++) _buildNumBtn(i.toString()),
                    const SizedBox(), // Espacio vacío
                    _buildNumBtn("0"),
                    IconButton(
                      icon: const Icon(Icons.backspace_outlined),
                      onPressed: _onBackspace,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumBtn(String number) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade100,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => _onNumberPress(number),
      child: Text(number, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }
}