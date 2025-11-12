import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/denuncia.dart';

class ApiService {
  // 🌐 URL base (sin /api al final)
  static const String baseUrl =
      'https://compossible-stephane-pesteringly.ngrok-free.dev';

  // ===========================
  // 📤 CREAR NUEVA DENUNCIA
  // ===========================
  static Future<bool> crearDenuncia(
    String correo,
    String descripcion,
    String ubicacion,
    File imagen,
  ) async {
    try {
      // 🖼️ Convertir imagen a Base64
      final bytes = await imagen.readAsBytes();
      final img64 = base64Encode(bytes);

      // 📦 Crear JSON a enviar
      final body = jsonEncode({
        "correo": correo,
        "descripcion": descripcion,
        "ubicacion": ubicacion,
        "foto": img64,
      });

      // 🚀 Enviar solicitud POST
      final res = await http.post(
        Uri.parse('$baseUrl/api/denuncias'),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print('📡 [POST] ${res.statusCode}: ${res.body}');
      if (res.statusCode == 201) {
        print('✅ Denuncia enviada con éxito');
        return true;
      } else {
        print('⚠️ Error al enviar denuncia: ${res.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error en crearDenuncia: $e');
      return false;
    }
  }

  // ===========================
  // 📋 OBTENER TODAS LAS DENUNCIAS
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
}
