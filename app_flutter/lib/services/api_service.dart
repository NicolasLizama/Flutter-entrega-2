// lib/services/api_service.dart

import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';
import '../models/denuncia.dart';
import 'dio_client.dart';

class ApiService {
  final Dio _dio = DioClient.dio;

  // ===========================
  // 📤 CREAR NUEVA DENUNCIA
  // ===========================
  Future<bool> crearDenuncia(
    String correo,
    String descripcion,
    String ubicacion,
    File imagen,
  ) async {
    try {
      final bytes = await imagen.readAsBytes();
      final img64 = base64Encode(bytes);

      final data = {
        "correo": correo,
        "descripcion": descripcion,
        "ubicacion": ubicacion,
        "foto": img64,
      };

      final res = await _dio.post("/api/denuncias", data: data);

      return res.statusCode == 201;
    } catch (e) {
      print("❌ Error en crearDenuncia: $e");
      return false;
    }
  }

  // ===========================
  // 📋 OBTENER TODAS LAS DENUNCIAS
  // ===========================
  Future<List<Denuncia>> getDenuncias() async {
    try {
      final res = await _dio.get("/api/denuncias");
      final List lista = res.data;
      return lista.map((e) => Denuncia.fromJson(e)).toList();
    } catch (e) {
      print("❌ Error en getDenuncias: $e");
      return [];
    }
  }
}
