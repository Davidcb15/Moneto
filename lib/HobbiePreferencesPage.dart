import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Databases/DatabaseHobbies.dart';
import 'models/hobby.dart';

class HobbiePreferencesPage extends StatefulWidget {
  const HobbiePreferencesPage({super.key});

  @override
  _HobbiePreferencesPageState createState() => _HobbiePreferencesPageState();
}

class _HobbiePreferencesPageState extends State<HobbiePreferencesPage> {
  List<Hobby> hobbies = [];

  // Mapa con los iconos para cada hobby
  final Map<String, IconData> hobbyIcons = {
    'Lectura': Icons.book,
    'Cocina': Icons.kitchen,
    'Música': Icons.music_note,
    'Deporte': Icons.fitness_center,
    'Escritura': Icons.create,
    'Fotografía': Icons.camera_alt,
    'Arte': Icons.palette,
    'Artesanía': Icons.handyman,
    'Bricolaje': Icons.build,
    'Juegos de mesa': Icons.games,
    'Idiomas': Icons.language,
    'Senderismo': Icons.directions_walk,
    'Meditar': Icons.self_improvement,
  };

  @override
  void initState() {
    super.initState();
    _loadHobbies();
  }

  Future<void> _loadHobbies() async {
    final dbHelper = DatabaseHelper.instance;

    List<Hobby> loadedHobbies = await dbHelper.getHobbies();

    // Si la base está vacía, añadimos una lista inicial
    if (loadedHobbies.isEmpty) {
      hobbies = [
        'Lectura', 'Cocina', 'Música', 'Deporte', 'Escritura',
        'Fotografía', 'Arte', 'Artesanía', 'Bricolaje', 'Juegos de mesa',
        'Idiomas', 'Senderismo', 'Meditar'
      ].map((name) => Hobby(name: name)).toList();
    } else {
      hobbies = loadedHobbies;
    }

    setState(() {});
  }

  Future<void> _saveSelectedHobbies() async {
    final dbHelper = DatabaseHelper.instance;

    await dbHelper.deleteAllHobbies();

    for (var hobby in hobbies) {
      if (hobby.isSelected) {
        await dbHelper.insertHobby(hobby);
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hobbie_preferences_set', true);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona tus hobbies')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: hobbies.map((hobby) {
                  // Verificamos si el hobby tiene un ícono
                  IconData hobbyIcon = hobbyIcons[hobby.name] ?? Icons.help;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        // Aquí mostramos el ícono
                        Icon(hobbyIcon, size: 30),
                        const SizedBox(width: 16), // Espacio entre el ícono y el texto
                        Expanded(
                          child: Text(
                            hobby.name,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        Checkbox(
                          value: hobby.isSelected,
                          onChanged: (bool? selected) {
                            setState(() {
                              hobby.isSelected = selected ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: _saveSelectedHobbies,
              child: const Text('Guardar preferencias'),
            ),
          ],
        ),
      ),
    );
  }
}
