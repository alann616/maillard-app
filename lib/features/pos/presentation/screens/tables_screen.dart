import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_theme.dart';

// Enum para simular estados (luego vendrá de la BD)
enum TableStatus { free, busy, paying }

class TablesScreen extends StatelessWidget {
  const TablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulamos datos reales con estados
    final tables = List.generate(12, (index) {
      // Truco para variar estados visualmente por ahora
      if (index == 2 || index == 5) return TableStatus.busy;
      if (index == 8) return TableStatus.paying;
      return TableStatus.free;
    });

    return Scaffold(
      backgroundColor: AppTheme.secondary,
      appBar: AppBar(
        title: const Text('Mapa de Mesas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // 1. Disparamos evento de salida
              context.read<AuthBloc>().add(LogoutRequested());
              // 2. Navegamos al login (GoRouter se encarga de limpiar el stack si lo configuramos, 
              // pero por ahora un go directo funciona)
              context.go('/login');
    },
  ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leyenda de Estados
            const _StatusLegend(),
            const SizedBox(height: 20),
            
            // Grid de Mesas
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 150, // Ancho máximo adaptable
                  childAspectRatio: 1.0,   // Cuadradas
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: tables.length,
                itemBuilder: (context, index) {
                  return _PosTableCard(
                    tableNumber: index + 1,
                    status: tables[index],
                    onTap: () => context.push('/menu/${index + 1}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET ATÓMICO: TARJETA DE MESA ---
class _PosTableCard extends StatelessWidget {
  final int tableNumber;
  final TableStatus status;
  final VoidCallback onTap;

  const _PosTableCard({
    required this.tableNumber,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    final isFree = status == TableStatus.free;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFree ? Colors.grey.shade300 : color,
            width: isFree ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_restaurant_rounded, 
              size: 40, 
              color: isFree ? Colors.grey[400] : color
            ),
            const SizedBox(height: 8),
            Text(
              "Mesa $tableNumber",
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: isFree ? Colors.black87 : color
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getStatusText(status),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
              ),
            )
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.free: return AppTheme.accent; // Verde (o gris oscuro si prefieres)
      case TableStatus.busy: return Colors.orange[800]!;
      case TableStatus.paying: return AppTheme.error; // Rojo
    }
  }

  String _getStatusText(TableStatus status) {
    switch (status) {
      case TableStatus.free: return "LIBRE";
      case TableStatus.busy: return "OCUPADA";
      case TableStatus.paying: return "PAGANDO";
    }
  }
}

// --- WIDGET ATÓMICO: LEYENDA ---
class _StatusLegend extends StatelessWidget {
  const _StatusLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _LegendItem(color: AppTheme.accent, label: "Libre"),
        _LegendItem(color: Colors.orange[800]!, label: "Ocupada"),
        _LegendItem(color: AppTheme.error, label: "Pagando"),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
      ],
    );
  }
}