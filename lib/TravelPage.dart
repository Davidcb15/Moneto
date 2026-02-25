import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Databases/DatabaseTravel.dart'; // Importar el archivo de la base de datos

class TravelPage extends StatefulWidget {
  const TravelPage({super.key});

  @override
  State<TravelPage> createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage> {
  double flightsTotal = 0.0;
  double accommodationTotal = 0.0;
  double mealsTotal = 0.0;
  double boatTotal = 0.0;
  double othersTotal = 0.0;

  bool _isFlightsOpen = false;
  bool _isAccommodationOpen = false;
  bool _isMealsOpen = false;
  bool _isBoatOpen = false;
  bool _isOthersOpen = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    flightsTotal = await DatabaseTravel.getTotal('Vuelos');
    accommodationTotal = await DatabaseTravel.getTotal('Alojamientos');
    mealsTotal = await DatabaseTravel.getTotal('Comidas');
    boatTotal = await DatabaseTravel.getTotal('Barco');
    othersTotal = await DatabaseTravel.getTotal('Otros gastos');
    setState(() {});
  }

  _showAddExpenseDialog(String category) {
    TextEditingController dateController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    TextEditingController detailController = TextEditingController();
    DateTime selectedDate = DateTime.now(); // Para el DatePicker

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
                  TextField(
                    controller: detailController,
                    decoration: InputDecoration(
                      labelText: category == 'Otros gastos' ? 'Actividad' : 'Destino',
                    ),
                    keyboardType: TextInputType.text,
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
                    if (amountController.text.isNotEmpty && detailController.text.isNotEmpty) {
                      double amount = double.parse(amountController.text);
                      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate); // Formatea la fecha para la BD
                      _saveExpense(category, amount, formattedDate, detailController.text);
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, completa todos los campos')),
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

  _saveExpense(String category, double amount, String fecha, String detail) async {
    await DatabaseTravel.insertGasto(category, fecha, amount, detail);
    _loadData();
  }

  _deleteExpense(String category, int id) async {
    await DatabaseTravel.deleteGasto(id);
    _loadData();
  }

  _showTotalDialog(String category, double total) async {
    List<Map<String, dynamic>> gastos = await DatabaseTravel.getGastos(category);

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
                        : 'Total: ${NumberFormat.currency(locale: 'es_ES', symbol: '€').format(total)}', // Formatear a Euros
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (gastos.isNotEmpty)
                    const Text('Detalles:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...List.generate(gastos.length, (i) {
                    final g = gastos[i];
                    return ListTile(
                      dense: true,
                      // Formatear a Euros y mostrar fecha
                      title: Text('📅 ${DateFormat('dd/MM/yyyy').format(DateTime.parse(g['fecha']))} — ${NumberFormat.currency(locale: 'es_ES', symbol: '€').format(g['importe'])} — ${g['detalle']}'),
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

  _showEditExpenseDialog(String category, Map<String, dynamic> gasto, int index) {
    // Usar DateTime.parse para convertir la fecha de la base de datos a DateTime
    DateTime selectedDate = DateTime.parse(gasto['fecha']);
    TextEditingController amountController = TextEditingController(text: gasto['importe'].toString());
    TextEditingController detailController = TextEditingController(
      text: category == 'Otros gastos' ? gasto['detalle'] : gasto['detalle'],
    );

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
                  TextField(
                    controller: detailController,
                    decoration: InputDecoration(
                      labelText: category == 'Otros gastos' ? 'Actividad' : 'Destino',
                    ),
                    keyboardType: TextInputType.text,
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
                    if ( amountController.text.isNotEmpty && detailController.text.isNotEmpty) {
                      double amount = double.parse(amountController.text);
                      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
                      _updateExpense(category, amount, formattedDate, detailController.text, gasto['id']);
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, completa todos los campos')),
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

  _updateExpense(String category, double amount, String fecha, String detail, int id) async {
    await DatabaseTravel.updateGasto(id, fecha, amount, detail);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalles del Viaje')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categorías de Viaje',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildCategoryTile('Vuelos', Icons.flight, _isFlightsOpen, flightsTotal, () => setState(() => _isFlightsOpen = !_isFlightsOpen)),
            _buildCategoryTile('Alojamientos', Icons.hotel, _isAccommodationOpen, accommodationTotal, () => setState(() => _isAccommodationOpen = !_isAccommodationOpen)),
            _buildCategoryTile('Comidas', Icons.fastfood, _isMealsOpen, mealsTotal, () => setState(() => _isMealsOpen = !_isMealsOpen)),
            _buildCategoryTile('Barco', Icons.directions_boat, _isBoatOpen, boatTotal, () => setState(() => _isBoatOpen = !_isBoatOpen)),
            _buildCategoryTile('Otros gastos', Icons.more_horiz, _isOthersOpen, othersTotal, () => setState(() => _isOthersOpen = !_isOthersOpen)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(String title, IconData icon, bool isOpen, double total, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: _buildCategoryCard(title, icon, isOpen, total, title),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, bool isOpen, double total, String category) {
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
              total == 0.0 ? 'No has realizado ningún gasto en $title.' : 'Total gastado: ${NumberFormat.currency(locale: 'es_ES', symbol: '€').format(total)}', // Formato moneda
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