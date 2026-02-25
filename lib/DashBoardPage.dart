import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gastos_compartidos_tfg/TransportPage.dart';
import 'package:gastos_compartidos_tfg/HomeSectionPage.dart';
import 'package:gastos_compartidos_tfg/HobbiePage.dart';
import 'package:gastos_compartidos_tfg/HobbiePreferencesPage.dart';
import 'package:gastos_compartidos_tfg/SaveMoneyPage.dart';
import 'package:gastos_compartidos_tfg/MoneyPage.dart';
import 'package:gastos_compartidos_tfg/ReportPage.dart';

class DashboardPage extends StatelessWidget {
  final String name;

  const DashboardPage({super.key, required this.name});
  // Mapa para mostrar todas las imagenes desde assets y en orden
  final List<Map<String, String>> categories = const [
    {
      'title': 'Transporte',
      'image': 'assets/transporte.png',
    },
    {
      'title': 'Ocio',
      'image': 'assets/ocio.png',
    },
    {
      'title': 'Hogar',
      'image': 'assets/hogar.png',
    },
    {
      'title': 'Ahorros',
      'image': 'assets/ahorro.png',
    },
    {
      'title': 'Ingresos',
      'image': 'assets/ingresos.png',
    },
    {
      'title': 'Generar Reportes',
      'image': 'assets/reportes.png',
    },
  ];

  // Método para comprobar si las preferencias ya están guardadas
  Future<bool> _checkIfPreferencesExist() async {
    final prefs = await SharedPreferences.getInstance();
    // Verificamos si la clave 'hobbie_preferences_set' existe y es true
    return prefs.getBool('hobbie_preferences_set') ?? false;
  }
  // Estilos de las tarjetas con las imagenes
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moneto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Bienvenido, $name!',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () async {
                      if (category['title'] == 'Transporte') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TransportPage(),
                          ),
                        );
                      }
                      else if (category['title'] == 'Ocio') {
                        bool preferencesSet = await _checkIfPreferencesExist();
                        if (preferencesSet) {
                          // Si las preferencias están configuradas, llevar al usuario a la página de hobbies
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HobbiePage(),
                            ),
                          );
                        } else {
                          // Si no están configuradas, llevar al formulario de preferencias
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HobbiePreferencesPage(),
                            ),
                          );
                        }
                      }
                      else if (category['title'] == 'Ahorros') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SaveMoneyPage(),
                          ),
                        );
                      }
                      else if (category['title'] == 'Ingresos') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MoneyPage(),
                          ),
                        );
                      }
                      else if (category['title'] == 'Hogar') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeSectionPage(),
                          ),
                        );
                      }
                      else if (category['title'] == 'Generar Reportes') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReportPage(),
                          ),
                        );
                      }
                      // Puedes seguir añadiendo condiciones para otras categorías si las necesitas
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
                                category['image']!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              category['title']!,
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
          ],
        ),
      ),
    );
  }
}
