import 'package:flutter/material.dart';
import 'package:gastos_compartidos_tfg/CarPage.dart';
import 'package:gastos_compartidos_tfg/PublicTransportPage.dart';
import 'package:gastos_compartidos_tfg/TravelPage.dart';

class TransportPage extends StatelessWidget {
  const TransportPage({super.key});

  final List<Map<String, String>> transportOptions = const [
    {
      'title': 'Coche',
      'image': 'assets/coche.png', // Asegúrate de que las imágenes estén en esta ruta
    },
    {
      'title': 'Transporte público',
      'image': 'assets/autobus.png',
    },
    {
      'title': 'Viajes',
      'image': 'assets/avion.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transporte')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: transportOptions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final transport = transportOptions[index];
            return GestureDetector(
              onTap: () {
                // Aquí se maneja la navegación
                if (transport['title'] == 'Coche') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CarPage(),
                    ),
                  );
                } else if (transport['title'] == 'Transporte público') {
                  // Puedes agregar la página de transporte público aquí
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PublicTransportPage(),
                    ),
                  );
                } else if (transport['title'] == 'Viajes') {
                  // Puedes agregar la página de viajes aquí
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TravelPage(),
                    ),
                  );
                }
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          transport['image']!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        transport['title']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
