import 'package:shared_preferences/shared_preferences.dart';

class Auth {
  // Guardar el correo del usuario en SharedPreferences
  Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
  }

  // Obtener el correo del usuario desde SharedPreferences
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  // Eliminar el correo del usuario de SharedPreferences (Cerrar sesión)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
  }

  // Verificar si el usuario ya está logueado
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('email');
  }
}
