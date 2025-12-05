import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Instancia del almacenamiento seguro
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // Guardar token de forma segura
  Future<void> guardarToken(String token) async {
    await storage.write(key: 'token', value: token);
  }

  // Leer token almacenado
  Future<String?> leerToken() async {
    return await storage.read(key: 'token');
  }

  // Borrar token al cerrar sesión
  Future<void> borrarToken() async {
    await storage.delete(key: 'token');
  }
}
