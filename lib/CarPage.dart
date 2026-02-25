import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Databases/DatabaseCar.dart';

class CarPage extends StatefulWidget {
  const CarPage({super.key});

  @override
  State<CarPage> createState() => _CarPageState();
}

class _CarPageState extends State<CarPage> {
  double revisionTotal = 0.0;
  double gasolinaTotal = 0.0;
  double mantenimientoTotal = 0.0;

  bool _isRevisionOpen = false;
  bool _isGasolinaOpen = false;
  bool _isMantenimientoOpen = false;
  // Carga los totales de cada categoría
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  // Metodo para cargar los totales de cada categoría desde la base de datos
  _loadData() async {
    revisionTotal = await DatabaseCar.getTotal('Revisión');
    gasolinaTotal = await DatabaseCar.getTotal('Gasolina');
    mantenimientoTotal = await DatabaseCar.getTotal('Mantenimiento');
    setState(() {});
  }
  // Dialogo para agregar nuevo gasto
  _showAddExpenseDialog(String category) {
    TextEditingController amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Agregar gasto en $category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                      const Spacer(),
                      TextButton(
                        child: const Text("Seleccionar fecha"),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setStateDialog(() => selectedDate = picked);
                          }
                        },
                      )
                    ],
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Importe'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (amountController.text.isNotEmpty) {
                      double amount = double.tryParse(amountController.text) ?? 0;
                      if (amount > 0) {
                        _saveExpense(category, amount, selectedDate);
                        Navigator.of(context).pop();
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, completa los campos')),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // Guarda los gastos
  _saveExpense(String category, double amount, DateTime fecha) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(fecha);
    await DatabaseCar.insertGasto(category, formattedDate, amount);
    _loadData();
  }
  // Elimina los gastos
  _deleteExpense(String category, int index) async {
    List<Map<String, dynamic>> gastos = await DatabaseCar.getGastos(category);
    if (index < 0 || index >= gastos.length) return;

    double importe = gastos[index]['importe'] ?? 0.0;
    await DatabaseCar.deleteGasto(gastos[index]['id']);
    setState(() {
      _loadData();
    });
  }
  // Muestra todos los gastos en una mini ventana
  _showTotalDialog(String category, double total) async {
    List<Map<String, dynamic>> gastos = await DatabaseCar.getGastos(category);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Total gastado en $category'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    total == 0.0
                        ? 'No has realizado ningún gasto en $category.'
                        : 'Total: ${total.toStringAsFixed(2)} €',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (gastos.isNotEmpty)
                    const Text('Detalles:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...List.generate(gastos.length, (i) {
                    final g = gastos[i];
                    return ListTile(
                      dense: true,
                      // Formatear el importe a euros
                      title: Text(
                          '📅 ${DateFormat('dd/MM/yyyy').format(DateTime.parse(g['fecha']))} — ${NumberFormat.currency(locale: 'es_ES', symbol: '€').format(g['importe'])}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteExpense(category, i);
                              setStateDialog(() {
                                gastos.removeAt(i);
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showEditExpenseDialog(category, g, i);
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          );
        });
      },
    );
  }
  // Editar los gastos
  _showEditExpenseDialog(String category, Map<String, dynamic> gasto, int index) {
    TextEditingController amountController = TextEditingController(text: gasto['importe'].toString());
    DateTime selectedDate = DateTime.parse(gasto['fecha']);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Editar gasto en $category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                      const Spacer(),
                      TextButton(
                        child: const Text("Seleccionar fecha"),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setStateDialog(() => selectedDate = picked);
                          }
                        },
                      )
                    ],
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Importe'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (amountController.text.isNotEmpty) {
                      double amount = double.tryParse(amountController.text) ?? 0;
                      if (amount > 0) {
                        _updateExpense(category, amount, selectedDate, index);
                        Navigator.of(context).pop();
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, completa los campos')),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // Actaliza los gastos
  _updateExpense(String category, double amount, DateTime fecha, int index) async {
    List<Map<String, dynamic>> gastos = await DatabaseCar.getGastos(category); // Obtener la lista de gastos

    if (index < 0 || index >= gastos.length) return; // Verificar el índice

    String formattedDate = DateFormat('yyyy-MM-dd').format(fecha);
    await DatabaseCar.updateGasto(gastos[index]['id'], formattedDate, amount); // Usar el índice para acceder al gasto correcto
    setState(() {
      _loadData();
    });
  }
  // Construye el widget con las tarjetas
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalles del Coche')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categorías de Transporte',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => setState(() => _isRevisionOpen = !_isRevisionOpen),
              child: _buildCategoryCard(
                'Revisión',
                Icons.lock,
                _isRevisionOpen,
                revisionTotal,
                'Revisión',
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _isGasolinaOpen = !_isGasolinaOpen),
              child: _buildCategoryCard(
                'Gasolina',
                Icons.local_gas_station,
                _isGasolinaOpen,
                gasolinaTotal,
                'Gasolina',
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _isMantenimientoOpen = !_isMantenimientoOpen),
              child: _buildCategoryCard(
                'Mantenimiento',
                Icons.build,
                _isMantenimientoOpen,
                mantenimientoTotal,
                'Mantenimiento',
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Tarjetas
  Widget _buildCategoryCard(
      String title,
      IconData icon,
      bool isOpen,
      double total,
      String category,
      ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, size: 40),
            title: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              total == 0.0
                  ? 'No has realizado ningún gasto en $title.'
                  : 'Total gastado: ${total.toStringAsFixed(2)} €',
            ),
            trailing: Icon(isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
          ),
          if (isOpen)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _showTotalDialog(category, total),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Cambiado a negro
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Ver total en $category'),
                  ),
                  ElevatedButton(
                    onPressed: () => _showAddExpenseDialog(category),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Cambiado a negro
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Agregar gasto en $category'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

