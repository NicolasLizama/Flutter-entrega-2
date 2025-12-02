import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/denuncia.dart';

class ApiService {
  // 🌐 URL base de tu API Flask
  static const String baseUrl =
      'https://implicit-neta-rostrally.ngrok-free.dev';

  // 🔐 Storage seguro para JWT
  static final _storage = FlutterSecureStorage();

  // ===========================
  // 🔑 OBTENER JWT
  // ===========================
  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt');
  }

  // ===========================
  // 🗑 LOGOUT USUARIO (BORRA JWT)
  // ===========================
  static Future<void> logout() async {
    await _storage.delete(key: 'jwt');
  }

  // ===========================
  // 🔒 PETICIÓN GET PROTEGIDA
  // ===========================
  static Future<http.Response?> _getProtected(String endpoint) async {
    try {
      final token = await getToken();
      if (token == null) return null;

      return await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {"Authorization": "Bearer $token"},
      );
    } catch (e) {
      print('❌ Error en GET $endpoint: $e');
      return null;
    }
  }

  // ===========================
  // 🔒 PETICIÓN POST PROTEGIDA
  // ===========================
  static Future<http.Response?> _postProtected(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final token = await getToken();
      if (token == null) return null;

      return await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      print('❌ Error en POST $endpoint: $e');
      return null;
    }
  }

  // ===========================
  // 📋 LISTAR DENUNCIAS
  // ===========================
  static Future<List<Denuncia>> getDenuncias() async {
    final res = await _getProtected('/api/denuncias');
    if (res != null && res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Denuncia.fromJson(e)).toList();
    }
    return [];
  }

  // ===========================
  // 📤 CREAR DENUNCIA
  // ===========================
  static Future<bool> crearDenuncia(
      String correo, String descripcion, String ubicacion, File imagen) async {
    try {
      final bytes = await imagen.readAsBytes();
      final img64 = base64Encode(bytes);

      final body = {
        "correo": correo,
        "descripcion": descripcion,
        "ubicacion": ubicacion,
        "foto": img64,
      };

      final res = await _postProtected('/api/denuncias', body);
      return res != null && res.statusCode == 201;
    } catch (e) {
      print('❌ Error en crearDenuncia: $e');
      return false;
    }
  }

  // ===========================
  // 👤 CREAR USUARIO
  // ===========================
  static Future<bool> crearUsuario(String correo, String password) async {
    try {
      final body = {"correo": correo, "password": password};

      final res = await http.post(
        Uri.parse('$baseUrl/api/crear_user'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      return res.statusCode == 201;
    } catch (e) {
      print('❌ Error en crearUsuario: $e');
      return false;
    }
  }

  // ===========================
  // 🔐 LOGIN USUARIO (GUARDA JWT)
  // ===========================
  static Future<bool> loginUsuario(String correo, String password) async {
    try {
      final body = {"correo": correo, "password": password};

      final res = await http.post(
        Uri.parse('$baseUrl/api/login_user'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final token = data['token'];
        if (token != null) {
          await _storage.write(key: 'jwt', value: token);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('❌ Error en loginUsuario: $e');
      return false;
    }
  }
}
