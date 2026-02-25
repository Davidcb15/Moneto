import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiénes somos"),
        backgroundColor: Colors.white, // Cambiado a blanco
        foregroundColor: Colors.black, // Asegura que el texto sea visible
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Texto explicativo de lo que hace la app
              Text(
                '¡Bienvenido a Moneto!\n\n'
                    'Esta aplicación te permite llevar el control de tus gastos personales, '
                    'ya sea solo o con tus amigos, familiares o compañeros de piso.\n\n'
                    'Puedes registrar tus gastos, asignarlos a categorías, y ver el progreso a lo largo del tiempo.\n\n'
                    'Podras tambien ver en que gastas mas y gastas menos con nuestros graficos para que sepas en todo momento en lo que gastas y cuanto.\n\n'
                    'Tambien podras generar PDF y graficos de tus gastos por si no tienes tiempo de entrar a la app pero quieres ver como vas con tus finanzas.\n\n'
                    '¡Gracias por usar Moneto y mantener tus finanzas bajo control!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
