import 'package:flutter/material.dart';
import 'models/hobby.dart';
import 'Databases/DatabaseHobbies.dart';
import 'package:intl/intl.dart';

class HobbiePage extends StatefulWidget {
  const HobbiePage({super.key});

  @override
  State<HobbiePage> createState() => _HobbiePageState();
}

class _HobbiePageState extends State<HobbiePage> {
  List<Hobby> selectedHobbies = [];
  final dbHelper = DatabaseHelper.instance;
  Map<String, double> totalExpenses = {};
  final Map<String, bool> _isExpandedMap = {}; // Para controlar la expansión

  // Mapa de íconos para cada hobby
  final Map<String, IconData> hobbyIcons = {
    'Lectura': Icons.book,
    'Cocina': Icons.kitchen,
    'Música': Icons.music_note,
    'Deporte': Icons.sports,
    'Escritura': Icons.edit,
    'Fotografía': Icons.camera_alt,
    'Arte': Icons.palette,
    'Artesanía': Icons.handyman,
    'Bricolaje': Icons.build,
    'Juegos de mesa': Icons.games,
    'Idiomas': Icons.language,
    'Senderismo': Icons.hiking,
    'Meditar': Icons.self_improvement,
  };

  @override
  void initState() {
    super.initState();
    _loadSelectedHobbies();
  }
  // Carga los hobbies desde la base de datos
  Future<void> _loadSelectedHobbies() async {
    final allHobbies = await dbHelper.getHobbies();
    selectedHobbies = allHobbies.where((h) => h.isSelected).toList();
    for (var hobby in selectedHobbies) {
      final total = await dbHelper.getTotalSpentForHobby(hobby.name);
      totalExpenses[hobby.name] = total;
      _isExpandedMap[hobby.name] = false; // Inicializar el estado de expansión
    }
    setState(() {});
  }
  // Edita o añade los hobbies
  Future<void> _addOrEditExpenseDialog(String hobbyName,
      {Map<String, dynamic>? expense}) async {
    final descController = TextEditingController(
        text: expense?['description'] ?? '');
    final amountController = TextEditingController(
        text: expense?['amount']?.toString() ?? '');
    DateTime selectedDate = expense != null
        ? DateTime.parse(expense['date'])
        : DateTime.now();

    await showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text(expense == null ? 'Agregar gasto' : 'Editar gasto'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: descController,
                    decoration: const InputDecoration(
                        labelText: 'Descripción')),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
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
                          setState(() => selectedDate = picked);
                        }
                      },
                    )
                  ],
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () async {
                  final desc = descController.text;
                  final amount =
                      double.tryParse(amountController.text) ?? 0;
                  if (desc.isNotEmpty && amount > 0) {
                    final dateStr = selectedDate.toIso8601String();
                    if (expense == null) {
                      await dbHelper.insertExpense(
                          hobbyName, desc, amount, dateStr);
                    } else {
                      await dbHelper.updateExpense(
                          expense['id'], desc, amount, dateStr);
                    }
                    await _loadSelectedHobbies();
                    Navigator.pop(context);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }
  // Muestra el total gastasdo en cada hobbie
  Future<void> _showExpensesDialog(String hobbyName) async {
    final expenses = await dbHelper.getExpensesForHobby(hobbyName);

    await showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Gastos en $hobbyName'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return ListTile(
                    title: Text(expense['description']),
                    subtitle: Text(
                        "${expense['amount']} € - ${DateFormat(
                            'dd/MM/yyyy').format(
                            DateTime.parse(expense['date']))}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _addOrEditExpenseDialog(hobbyName,
                                  expense: expense),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red),
                          onPressed: () async {
                            await dbHelper.deleteExpense(expense['id']);
                            await _loadSelectedHobbies();
                            Navigator.pop(context);
                            _showExpensesDialog(
                                hobbyName); // Recargar diálogo
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar')),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ocio")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: selectedHobbies.isEmpty
            ? const Center(child: Text("No has seleccionado hobbies aún."))
            : ListView.builder(
          itemCount: selectedHobbies.length,
          itemBuilder: (context, index) {
            final hobby = selectedHobbies[index];
            final total = totalExpenses[hobby.name] ?? 0;
            final icon = hobbyIcons[hobby.name] ?? Icons.help;
            final isExpanded = _isExpandedMap[hobby.name] ??
                false; // Obtener el estado de expansión

            return GestureDetector(
              onTap: () {
                setState(() {
                  _isExpandedMap[hobby.name] =
                  !isExpanded; // Cambiar el estado al tocar
                });
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(icon, size: 40),
                      title: Text(
                        hobby.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        total == 0
                            ? 'No has realizado ningún gasto en ${hobby
                            .name}.' //texto igual
                            : 'Total gastado: ${total.toStringAsFixed(
                            2)} €', //texto igual
                      ),
                      trailing: Icon(
                        isExpanded
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                      ),
                    ),
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () =>
                                  _showExpensesDialog(hobby.name),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black, // Cambiado a negro
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Ver gastos"),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () =>
                                  _addOrEditExpenseDialog(hobby.name),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black, // Cambiado a negro
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                  "Agregar gasto en ${hobby.name}"),
                            ),
                          ],
                        ),
                      ),
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

