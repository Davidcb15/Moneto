import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Databases/DatabasePublicTransport.dart';

class PublicTransportPage extends StatefulWidget {
  const PublicTransportPage({super.key});

  @override
  State<PublicTransportPage> createState() => _PublicTransportPageState();
}

class _PublicTransportPageState extends State<PublicTransportPage> {
  double busTotal = 0.0;
  double metroTotal = 0.0;
  double taxiTotal = 0.0;

  bool _isBusOpen = false;
  bool _isMetroOpen = false;
  bool _isTaxiOpen = false;
  // Llama al metodo para cargar
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  // Cargar desde la base de datos
  _loadData() async {
    busTotal = await DatabasePublicTransport.getTotal('Bus');
    metroTotal = await DatabasePublicTransport.getTotal('Metro');
    taxiTotal = await DatabasePublicTransport.getTotal('Taxi');
    setState(() {});
  }
  // Añadir nuevo gasto
  _showAddExpenseDialog(String category) {
    DateTime selectedDate = DateTime.now();
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) { //Usamos el setState del builder
            return AlertDialog(
              title: Text('Agregar gasto en $category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(DateFormat('dd/MM/yyyy').format(selectedDate)), // Muestra la fecha formateada
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
                            setStateDialog(() { // Actualiza la fecha seleccionada
                              selectedDate = picked;
                            });
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
                      double amount = double.parse(amountController.text);
                      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
                      _saveExpense(category, amount, formattedDate);
                      Navigator.of(context).pop();
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
  // Guardar los gastos
  _saveExpense(String category, double amount, String fecha) async {
    await DatabasePublicTransport.insertGasto(category, fecha, amount);
    _loadData();
  }
  // ELiminar gastsos
  _deleteExpense(String category, int id) async {
    await DatabasePublicTransport.deleteGasto(id);
    _loadData();
  }
  // Mostar el total
  _showTotalDialog(String category, double total) async {
    List<Map<String, dynamic>> gastos = await DatabasePublicTransport.getGastos(category);

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
                    // Formatea la salida como euros
                        : 'Total: ${NumberFormat.currency(locale: 'es_ES', symbol: '€').format(total)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (gastos.isNotEmpty)
                    const Text('Detalles:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...List.generate(gastos.length, (i) {
                    final g = gastos[i];
                    return ListTile(
                      dense: true,
                      // Formatea la fecha y el importe para mostrar correctamente
                      title: Text(
                          '📅 ${DateFormat('dd/MM/yyyy').format(DateTime.parse(g['fecha']))} — ${NumberFormat.currency(locale: 'es_ES', symbol: '€').format(g['importe'])}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteExpense(category, g['id']);
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
    DateTime selectedDate = DateTime.parse(gasto['fecha']);
    TextEditingController amountController = TextEditingController(text: gasto['importe'].toString());

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
                            setStateDialog(() {
                              selectedDate = picked;
                            });
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
                      double amount = double.parse(amountController.text);
                      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
                      _updateExpense(category, amount, formattedDate, gasto['id']);
                      Navigator.of(context).pop();
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
  // Actualiza los gastos
  _updateExpense(String category, double amount, String fecha, int id) async {
    await DatabasePublicTransport.updateGasto(id, fecha, amount);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalles del Transporte Público')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categorías de Transporte Público',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => setState(() => _isBusOpen = !_isBusOpen),
              child: _buildCategoryCard(
                'Bus',
                Icons.directions_bus,
                _isBusOpen,
                busTotal,
                'Bus',
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _isMetroOpen = !_isMetroOpen),
              child: _buildCategoryCard(
                'Metro',
                Icons.directions_subway,
                _isMetroOpen,
                metroTotal,
                'Metro',
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _isTaxiOpen = !_isTaxiOpen),
              child: _buildCategoryCard(
                'Taxi',
                Icons.local_taxi,
                _isTaxiOpen,
                taxiTotal,
                'Taxi',
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Construye las tarjetas
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
              // Formatea la salida como euros
                  : 'Total gastado: ${NumberFormat.currency(locale: 'es_ES', symbol: '€').format(total)}',
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
                      backgroundColor: Colors.black, // Botón negro
                      foregroundColor: Colors.white, // Texto blanco
                    ),
                    child: Text('Ver total en $category'),
                  ),
                  ElevatedButton(
                    onPressed: () => _showAddExpenseDialog(category),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Botón negro
                      foregroundColor: Colors.white, // Texto blanco
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