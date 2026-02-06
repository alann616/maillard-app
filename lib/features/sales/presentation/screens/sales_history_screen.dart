import 'package:app/config/theme/app_theme.dart';
import 'package:app/features/sales/presentation/bloc/sales_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SalesHistoryScreen extends StatelessWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Forzamos la recarga al entrar para tener datos frescos
    // (Útil si acabas de hacer una venta y entras aquí)
    context.read<SalesBloc>().add(LoadSalesHistory());

    return Scaffold(
      backgroundColor: AppTheme.secondary,
      appBar: AppBar(
        title: const Text("Historial de Ventas"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<SalesBloc, SalesState>(
        builder: (context, state) {
          if (state is SalesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SalesError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          if (state is SalesLoaded) {
            if (state.sales.isEmpty) {
              return const Center(child: Text("No hay ventas registradas aún."));
            }

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // 1. TARJETA DE RESUMEN (BI)
                  _SummaryCard(total: state.totalRevenue, count: state.sales.length),
                  
                  const SizedBox(height: 20),
                  
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Tickets Recientes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  
                  const SizedBox(height: 10),

                  // 2. LISTA DE VENTAS
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.sales.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final sale = state.sales[index];
                        return _SaleTile(
                          id: sale.id,
                          total: sale.total,
                          date: sale.date,
                        );
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

// --- WIDGETS AUXILIARES (Para mantener limpio el código) ---

class _SummaryCard extends StatelessWidget {
  final double total;
  final int count;

  const _SummaryCard({required this.total, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ventas Totales",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Text(
            "\$${total.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.receipt_long, color: Colors.white70, size: 16),
              const SizedBox(width: 5),
              Text(
                "$count transacciones cerradas",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SaleTile extends StatelessWidget {
  final int id;
  final double total;
  final DateTime date;

  const _SaleTile({required this.id, required this.total, required this.date});

  @override
  Widget build(BuildContext context) {
    // Formateo manual simple de fecha para no depender de paquetes extra por ahora
    final dateString = "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ticket #$id", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(dateString, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          Text(
            "\$${total.toStringAsFixed(2)}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}