import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class TablesScreen extends StatelessWidget {
  const TablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos dummy para probar visualmente
    final tables = List.generate(12, (index) => 'Mesa ${index + 1}');

    return Scaffold(
      appBar: AppBar(
        title: Text('MAILLARD POS', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 mesas por fila
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: tables.length,
          itemBuilder: (context, index) {
            return _TableCard(
              tableName: tables[index],
              onTap: () {
                // Navegación con GoRouter pasando el ID de la mesa
                context.push('/menu/${index + 1}');
              },
            );
          },
        ),
      ),
    );
  }
}

// Widget privado para diseñar la tarjeta de la mesa
class _TableCard extends StatelessWidget {
  final String tableName;
  final VoidCallback onTap;

  const _TableCard({required this.tableName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blueGrey[50], // Color de mesa libre
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueGrey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.table_restaurant, size: 40, color: Colors.blueGrey),
              const SizedBox(height: 10),
              Text(
                tableName,
                style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const Text("Libre", style: TextStyle(color: Colors.green, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}