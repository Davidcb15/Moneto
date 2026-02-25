// Clase para obtener los hobbies de la lista de preferencias, para despues mostrar las tarjetas de los hobbies seleccionados
class Hobby {
  final int? id;
  final String name;
  bool isSelected;

  Hobby({this.id, required this.name, this.isSelected = false});

  factory Hobby.fromMap(Map<String, dynamic> json) => Hobby(
    id: json['id'],
    name: json['name'],
    isSelected: json['isSelected'] == 1,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'isSelected': isSelected ? 1 : 0,
  };
}
