import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuScreen extends StatelessWidget {
  final String tableId;

  const MenuScreen({super.key, required this.tableId});

  @override
  Widget build(BuildContext context) {
    // Datos dummy de productos
    final products = [
      {'name': 'Espresso Doble', 'price': 45.0},
      {'name': 'Latte 10oz', 'price': 65.0},
      {'name': 'Flat White', 'price': 60.0},
      {'name': 'Cold Brew', 'price': 70.0},
      {'name': 'V60 Método', 'price': 85.0},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Mesa $tableId', style: GoogleFonts.jetBrainsMono()),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // Lado Izquierdo: Lista de Productos
          Expanded(
            flex: 2,
            child: ListView.separated(
              padding: const EdgeInsets.all(10),
              itemCount: products.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    color: Colors.brown[100],
                    child: const Icon(Icons.coffee, color: Colors.brown),
                  ),
                  title: Text(product['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('\$${product['price']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                    onPressed: () {
                      // Aquí pondremos la lógica el Lunes
                      print("Agregado ${product['name']}");
                    },
                  ),
                );
              },
            ),
          ),
          
          // Lado Derecho: La Comanda (Resumen) - Placeholder por hoy
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[200],
              child: const Center(child: Text("Aquí irá el Ticket")),
            ),
          ),
        ],
      ),
    );
  }
}