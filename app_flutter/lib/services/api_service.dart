import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/denuncia.dart';

class ApiService {
  static const String baseUrl =
      'https://implicit-neta-rostrally.ngrok-free.dev';

  // ===========================
  // 📤 CREAR DENUNCIA
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

      final body = jsonEncode({
        "correo": correo,
        "descripcion": descripcion,
        "ubicacion": ubicacion,
        "foto": img64,
      });

      final res = await http.post(
        Uri.parse('$baseUrl/api/denuncias'),
        headers: {"Content-Type": "application/json"},
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
  // 📋 LISTAR DENUNCIAS
  // ===========================
  static Future<List<Denuncia>> getDenuncias() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/denuncias'));

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
  // 👤 CREAR USUARIO (CORRECTO)
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
  // 🔐 LOGIN USUARIO (CORRECTO)
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

      return res.statusCode == 200;
    } catch (e) {
      print("❌ Error en loginUsuario: $e");
      return false;
    }
  }
}
