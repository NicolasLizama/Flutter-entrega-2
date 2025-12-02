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
  // 📤 CREAR DENUNCIA (PROTEGIDO)
  // ===========================
  static Future<bool> crearDenuncia(
    String correo,
    String descripcion,
    String ubicacion,
    File imagen,
  ) async {
    try {
      final bytes = await imagen.readAsBytes();
      final img64 = base64Encode(bytes);
      final token = await _storage.read(key: 'jwt');

      if (token == null) return false;

      final body = jsonEncode({
        "correo": correo,
        "descripcion": descripcion,
        "ubicacion": ubicacion,
        "foto": img64,
      });

      final res = await http.post(
        Uri.parse('$baseUrl/api/denuncias'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      print('📡 [POST DENUNCIA] ${res.statusCode}: ${res.body}');
      return res.statusCode == 201;
    } catch (e) {
      print('❌ Error en crearDenuncia: $e');
      return false;
    }
  }

  // ===========================
  // 📋 LISTAR DENUNCIAS (PROTEGIDO)
  // ===========================
  static Future<List<Denuncia>> getDenuncias() async {
    try {
      final token = await _storage.read(key: 'jwt');
      if (token == null) return [];

      final res = await http.get(
        Uri.parse('$baseUrl/api/denuncias'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Denuncia.fromJson(e)).toList();
      } else {
        print('⚠️ Error al cargar denuncias: ${res.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error en getDenuncias: $e');
      return [];
    }
  }

  // ===========================
  // 👤 CREAR USUARIO
  // ===========================
  static Future<bool> crearUsuario(
    String correo,
    String password,
  ) async {
    try {
      final body = jsonEncode({
        "correo": correo,
        "password": password,
      });

      final res = await http.post(
        Uri.parse('$baseUrl/api/crear_user'),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print("📡 [POST CREAR USER] ${res.statusCode}: ${res.body}");
      return res.statusCode == 201;
    } catch (e) {
      print("❌ Error en crearUsuario: $e");
      return false;
    }
  }

  // ===========================
  // 🔐 LOGIN USUARIO (GUARDA JWT)
  // ===========================
  static Future<bool> loginUsuario(
    String correo,
    String password,
  ) async {
    try {
      final body = jsonEncode({
        "correo": correo,
        "password": password,
      });

      final res = await http.post(
        Uri.parse('$baseUrl/api/login_user'),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print("📡 [POST LOGIN USER] ${res.statusCode}: ${res.body}");

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
      print("❌ Error en loginUsuario: $e");
      return false;
    }
  }

  // ===========================
  // 🗑 LOGOUT USUARIO (BORRA JWT)
  // ===========================
  static Future<void> logout() async {
    await _storage.delete(key: 'jwt');
  }

  // ===========================
  // 🔑 OBTENER JWT
  // ===========================
  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt');
  }
}
