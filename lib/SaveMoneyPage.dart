import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear la moneda
import 'Databases/DatabaseSaveMoney.dart'; // Importa la clase de la base de datos

class SaveMoneyPage extends StatefulWidget {
  const SaveMoneyPage({super.key});

  @override
  State<SaveMoneyPage> createState() => _SaveMoneyPageState();
}

class _SaveMoneyPageState extends State<SaveMoneyPage> {
  double totalSavings = 0.0;
  final _formKey = GlobalKey<FormState>(); // Clave para el formulario
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavings();
  }

  // Carga los ahorros desde la base de datos
  _loadSavings() async {
    totalSavings = await DatabaseSaveMoney.getTotalAhorros();
    setState(() {});
  }

  // Agrega ahorros a la base de datos
  _addSavings(double amount) async {
    if (amount <= 0) return; // No permitir montos negativos o cero

    setState(() {
      totalSavings += amount;
    });
    await DatabaseSaveMoney.insertOrUpdateAhorro(totalSavings);
    _loadSavings(); // Recargar los datos para asegurar la UI actualizada
  }

  // Muestra el diálogo para agregar ahorros
  _showAddDialog() {
    _amountController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Ahorro', style: TextStyle(fontWeight: FontWeight.w600)),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
                prefixIcon: Text('€'), // Cambiado a símbolo de euro
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingrese un monto.';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Ingrese un monto válido mayor que cero.';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final amount = double.parse(_amountController.text);
                  _addSavings(amount);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar( // Mostrar confirmación
                    const SnackBar(
                      content: Text('Ahorro agregado correctamente.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ahorros', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Añadido: Imagen del cerdito en blanco y negro
            ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0,      0,      0,      1, 0,
              ]),
              child: Image.asset(
                'assets/piggy_bank.png',
                height: 200,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0,      0,      0,      1, 0,
                    ]),
                    child: const Icon(Icons.savings, color: Colors.blue),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Dinero ahorrado: ${NumberFormat.currency(locale: 'es_ES', symbol: '€').format(totalSavings)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black), // Cambiado el color del texto a negro
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showAddDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Cambiado el color del botón a negro
                foregroundColor: Colors.white,  // Cambiado el color del texto del botón a blanco
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
              child: const Text('Agregar dinero a la hucha', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            const Text(
              "¡Cada céntimo cuenta!",
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}