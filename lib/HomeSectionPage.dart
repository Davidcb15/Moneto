import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Databases/DatabaseHome.dart';

class HomeSectionPage extends StatefulWidget {
  const HomeSectionPage({super.key});

  @override
  State<HomeSectionPage> createState() => _HomeSectionPageState();
}

class _HomeSectionPageState extends State<HomeSectionPage> {
  double alquilerTotal = 0.0;
  double aguaTotal = 0.0;
  double luzTotal = 0.0;
  double internetTotal = 0.0;
  double compraTotal = 0.0;

  bool _isAlquilerOpen = false;
  bool _isAguaOpen = false;
  bool _isLuzOpen = false;
  bool _isInternetOpen = false;
  bool _isCompraOpen = false;

  final dbHelper = DatabaseHome.instance; // Instancia de la base de datos
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy'); // Formato de fecha

  // Mapa de iconos para las categorías
  final Map<String, IconData> _categoryIcons = {
    'alquiler': Icons.home,
    'agua': Icons.water_drop,
    'luz': Icons.lightbulb,
    'internet': Icons.wifi,
    'compra': Icons.shopping_cart,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Carga los datos desde la base de datos
  _loadData() async {
    alquilerTotal = await dbHelper.getTotalForCategory('alquiler');
    aguaTotal = await dbHelper.getTotalForCategory('agua');
    luzTotal = await dbHelper.getTotalForCategory('luz');
    internetTotal = await dbHelper.getTotalForCategory('internet');
    compraTotal = await dbHelper.getTotalForCategory('compra');

    setState(() {});
  }

  // Muestra el diálogo para agregar gastos
  _showAddExpenseDialog(String categoryKey, String displayName) async {
    TextEditingController dateController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    DateTime selectedDate = DateTime.now(); // Para el DatePicker

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar gasto en $displayName'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Column(
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
                            dateController.text =
                                DateFormat('dd/MM/yyyy').format(selectedDate);
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
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              // Agregamos async
              if (amountController.text.isNotEmpty) {
                final amount = double.tryParse(amountController.text);
                if (amount != null) {
                  await _saveExpense(
                      categoryKey, amount, selectedDate); // Pasamos la fecha
                  Navigator.of(context).pop();
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Por favor, completa los campos')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Guarda el gasto en la base de datos
  _saveExpense(String category, double amount, DateTime date) async {
    try {
      await dbHelper.insertOrUpdateExpense(category, amount,
          date); // Modificamos la llamada para incluir la fecha
      _loadData(); // Recargar datos
    } catch (e) {
      print('Error en _saveExpense: $e'); // Log de error
      // Mostrar un mensaje de error al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el gasto: $e')),
      );
    }
  }

  // Muestra el diálogo con el total de gastos
  _showTotalDialog(String category, String displayName, double total) async {
    List<Map<String, dynamic>> gastos =
    await dbHelper.getGastosByCategory(category);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Total gastado en $displayName'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    total == 0.0
                        ? 'No has realizado ningún gasto en $displayName.'
                        : 'Total gastado: ${NumberFormat.currency(locale: 'es_ES', symbol: '€').format(total)}', // Formato moneda
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (gastos.isNotEmpty)
                    const Text('Detalles:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...List.generate(gastos.length, (i) {
                    final g = gastos[i];
                    return ListTile(
                      dense: true,
                      // Formatea la fecha para mostrarla
                      title: Text(
                          '📅 ${DateFormat('dd/MM/yyyy').format(DateTime.parse(g['fecha']))} — ${NumberFormat.currency(locale: 'es_ES', symbol: '€').format(g['importe'])}'), // Formato moneda
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

  _showEditExpenseDialog(
      String category, Map<String, dynamic> gasto, int index) {
    // Usa DateTime para la fecha
    DateTime selectedDate = DateTime.parse(gasto['fecha']);
    TextEditingController amountController =
    TextEditingController(text: gasto['importe'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          //Usar StatefulBuilder
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Editar gasto en $category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Formatear la fecha para mostrarla
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
                            // Actualizar el estado del diálogo
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
                      // Formatear la fecha antes de guardarla
                      String formattedDate =
                      DateFormat('yyyy-MM-dd').format(selectedDate);
                      _updateExpense(
                          category, amount, formattedDate, gasto['id']);
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                            Text('Por favor, completa todos los campos')),
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

  _updateExpense(String category, double amount, String fecha, int id) async {
    await dbHelper.updateGasto(id, fecha, amount);
    _loadData();
  }

  _deleteExpense(String category, int id) async {
    await dbHelper.deleteGasto(id);
    _loadData();
  }

  // Construye la sección de la UI para cada categoría de gasto
  Widget buildSection({
    required String title,
    required String key,
    required double total,
    required bool isExpanded,
    required VoidCallback onToggle,
    required String subtitle,
  }) {
    final categoryIcon = _categoryIcons[key] ??
        Icons
            .category; // Obtiene el ícono del mapa, usa uno genérico si no se encuentra
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            leading: Icon(categoryIcon, size: 40),
            title: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(total == 0.0
                ? 'No has realizado ningún gasto en $title'
                : subtitle),
            trailing: isExpanded
                ? const Icon(Icons.arrow_drop_up)
                : const Icon(Icons.arrow_drop_down),
            onTap: onToggle,
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Botones en negro
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _showTotalDialog(
                        key, title, total), // Pasar category a _showTotalDialog
                    child: Text('Ver total en $title'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style:  ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Botones en negro
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _showAddExpenseDialog(
                        key, title), // No pasamos fecha aquí
                    child: Text('Agregar gasto en $title'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gastos del Hogar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildSection(
              title: 'Alquiler',
              key: 'alquiler',
              total: alquilerTotal,
              isExpanded: _isAlquilerOpen,
              onToggle: () =>
                  setState(() => _isAlquilerOpen = !_isAlquilerOpen),
              subtitle:
              'Total gastado: ${NumberFormat.currency(locale: 'es_ES', symbol: '€').format(alquilerTotal)}', // Formato moneda
            ),
            buildSection(
              title: 'Agua',
              key: 'agua',
              total: aguaTotal,
              isExpanded: _isAguaOpen,
              onToggle: () => setState(() => _isAguaOpen = !_isAguaOpen),
              subtitle:
              'Total gastado: ${NumberFormat.currency(locale: 'es_ES', symbol: '€').format(aguaTotal)}', // Formato moneda
            ),
            buildSection(
              title: 'Luz',
              key: 'luz',
              total: luzTotal,
              isExpanded: _isLuzOpen,
              onToggle: () => setState(() => _isLuzOpen = !_isLuzOpen),
              subtitle:
              'Total gastado: ${NumberFormat.currency(locale: 'es_ES', symbol:  '€').format(luzTotal)}', // Formato moneda
            ),
            buildSection(
              title: 'Internet',
              key: 'internet',
              total: internetTotal,
              isExpanded: _isInternetOpen,
              onToggle: () =>
                  setState(() => _isInternetOpen = !_isInternetOpen),
              subtitle:
              'Total gastado: ${NumberFormat.currency(locale: 'es_ES', symbol: '€').format(internetTotal)}', // Formato moneda
            ),
            buildSection(
              title: 'Compra',
              key: 'compra',
              total: compraTotal,
              isExpanded: _isCompraOpen,
              onToggle: () => setState(() => _isCompraOpen = !_isCompraOpen),
              subtitle:
              'Total gastado: ${NumberFormat.currency(locale: 'es_ES', symbol: '€').format(compraTotal)}', // Formato moneda
            ),
          ],
        ),
      ),
    );
  }
}

