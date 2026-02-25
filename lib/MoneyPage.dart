import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Databases/DatabaseMoney.dart';

class MoneyPage extends StatefulWidget {
  const MoneyPage({super.key});

  @override
  State<MoneyPage> createState() => _MoneyPageState();
}

class _MoneyPageState extends State<MoneyPage> {
  double totalIngresos = 0.0;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Cargar los datos desde la base de datos
  _loadData() async {
    totalIngresos = await DatabaseMoney.getTotalIngresos();
    setState(() {});
  }

  // Función para guardar los ingresos en la base de datos
  _saveIncome(double amount) async {
    await DatabaseMoney.insertOrUpdateIngreso(totalIngresos + amount);
    _loadData();
  }

  // Función para mostrar un diálogo para agregar ingresos
  _showAddIncomeDialog() {
    // Limpiar controladores cada vez que se abre el diálogo
    _monthController.clear();
    _yearController.clear();
    _amountController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar ingreso', style: TextStyle(fontWeight: FontWeight.w600)),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0,      0,      0,      1, 0,
                  ]),
                  child: TextFormField(
                    controller: _monthController,
                    decoration: const InputDecoration(
                      labelText: 'Mes',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese el mes';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0,      0,      0,      1, 0,
                  ]),
                  child: TextFormField(
                    controller: _yearController,
                    decoration: const InputDecoration(
                      labelText: 'Año',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese el año';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Ingrese un año válido (número)';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad',
                    border: OutlineInputBorder(),
                    prefixIcon: Text('€'), // Usar el símbolo del euro
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese la cantidad';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Ingrese un monto válido (número mayor que cero)';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  double amount = double.parse(_amountController.text);
                  _saveIncome(amount);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ingreso agregado correctamente.'),
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
    // Limpiar los controladores cuando ya no se necesitan
    _monthController.dispose();
    _yearController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingresos', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white, // Cambiado a blanco
        foregroundColor: Colors.black, // Asegura que el texto sea visible
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Añadida imagen "money.png"
            Image.asset(
              'assets/money.png', // Asegúrate de que la ruta sea correcta
              height: 100, // Ajusta la altura según sea necesario
            ),
            const SizedBox(height: 20),
            // Mostrar el total de ingresos
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300), // Cambiado color del borde
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    'Total ingresado: ${NumberFormat.currency(locale: 'es_ES', symbol: '€').format(totalIngresos)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black), // Cambiado color del texto
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botón para agregar ingresos
            ElevatedButton(
              onPressed: _showAddIncomeDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Cambiado color del botón
                foregroundColor: Colors.white,  // Cambiado color del texto del botón
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
              child: const Text('Añadir ingreso', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            const Text(
              "Registra tus ingresos mensuales para tener un mejor control de tus finanzas.",
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

