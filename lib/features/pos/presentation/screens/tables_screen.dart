import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../bloc/table_bloc.dart';

class TablesScreen extends StatelessWidget {
  const TablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondary,
      appBar: AppBar(
        title: const Text(
          'Mapa de Mesas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2),
            tooltip: 'Ver Inventario',
            onPressed: () => context.push('/inventory'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              context.go('/login');
            },
          ),
        ],
      ),
      body: BlocBuilder<TableBloc, TableState>(
        builder: (context, state) {
          if (state is TableLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TableError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          if (state is TableLoaded) {
            final tables = state.tables;

            if (tables.isEmpty) {
              return const Center(child: Text("No hay mesas configuradas."));
            }

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StatusLegend(),
                  const SizedBox(height: 20),

                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 150,
                        // CAMBIO 1: Relación de aspecto 0.8 (Más alto que ancho)
                        // Esto da "aire" vertical para que quepa el total sin desbordar.
                        childAspectRatio: 0.80, 
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: tables.length,
                      itemBuilder: (context, index) {
                        final tableData = tables[index];
                        return _RealTableCard(tableData: tableData);
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _RealTableCard extends StatelessWidget {
  final TableWithStatus tableData;

  const _RealTableCard({required this.tableData});

  @override
  Widget build(BuildContext context) {
    final isOccupied = tableData.activeSale != null;
    
    final color = isOccupied ? Colors.orange[800]! : AppTheme.accent;
    final statusText = isOccupied ? "OCUPADA" : "LIBRE";
    final totalText = isOccupied ? "\$${tableData.activeSale!.total.toStringAsFixed(2)}" : "";

    return InkWell(
      onTap: () => context.push('/menu/${tableData.table.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12), // Padding interno seguro
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOccupied ? color : Colors.grey.shade300,
            width: isOccupied ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // CAMBIO 2: Column con espacio distribuido uniformemente
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
          children: [
            Icon(
              Icons.table_restaurant_rounded,
              size: 40,
              color: isOccupied ? color : Colors.grey[400],
            ),
            
            // CAMBIO 3: FittedBox para el nombre
            // Si el nombre es muy largo, se reduce en lugar de romper la UI
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                tableData.table.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isOccupied ? color : Colors.black87,
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (isOccupied)
                    // CAMBIO 4: FittedBox para el precio
                    // Evita overflow si el precio es millonario
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        totalText,
                        style: TextStyle(
                          fontSize: 11, // Un poco más grande para legibilidad
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLegend extends StatelessWidget {
  const _StatusLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _LegendItem(color: AppTheme.accent, label: "Libre"),
        _LegendItem(color: Colors.orange[800]!, label: "Ocupada"),
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
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        ),
      ],
    );
  }
}