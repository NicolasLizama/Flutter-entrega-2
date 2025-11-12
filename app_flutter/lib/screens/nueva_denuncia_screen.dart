import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'package:geolocator/geolocator.dart';

class NuevaDenunciaScreen extends StatefulWidget {
  const NuevaDenunciaScreen({super.key});

  @override
  State<NuevaDenunciaScreen> createState() => _NuevaDenunciaScreenState();
}

class _NuevaDenunciaScreenState extends State<NuevaDenunciaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();
  File? _imagen;
  bool _loading = false;

  // ============================
  // 📍 OBTENER UBICACIÓN ACTUAL
  // ============================
  Future<void> _obtenerUbicacionActual() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activa la ubicación para continuar')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de ubicación denegado')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Los permisos de ubicación están bloqueados permanentemente')),
      );
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _ubicacionCtrl.text = '${pos.latitude}, ${pos.longitude}';
    });
  }

  // ============================
  // 📸 SELECCIONAR IMAGEN (CÁMARA O GALERÍA)
  // ============================
  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();

    final opcion = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar imagen'),
        content: const Text('¿Desea tomar una foto o elegir de la galería?'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Cámara'),
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          ),
          TextButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text('Galería'),
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );

    if (opcion != null) {
      final picked = await picker.pickImage(source: opcion);
      if (picked != null) {
        setState(() => _imagen = File(picked.path));
      }
    }
  }

  // ============================
  // 🚀 ENVIAR FORMULARIO
  // ============================
  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate() || _imagen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() => _loading = true);

    final ok = await ApiService.crearDenuncia(
      _correoCtrl.text.trim(),
      _descCtrl.text.trim(),
      _ubicacionCtrl.text.trim(),
      _imagen!,
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (ok) {
      // ✅ Cerrar la pantalla antes de mostrar el mensaje
      Navigator.of(context).pop(true);

      // ✅ Mostrar mensaje en el listado principal
      Future.delayed(const Duration(milliseconds: 300), () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Denuncia enviada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Error al enviar denuncia'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================
  // 🧱 CONSTRUCCIÓN DEL FORMULARIO
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Denuncia'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _correoCtrl,
                  decoration: const InputDecoration(labelText: 'Correo'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Ingrese un correo' : null,
                ),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Ingrese una descripción' : null,
                ),
                TextFormField(
                  controller: _ubicacionCtrl,
                  decoration: const InputDecoration(labelText: 'Ubicación'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.my_location),
                  label: const Text('Usar mi ubicación actual'),
                  onPressed: _obtenerUbicacionActual,
                ),
                const SizedBox(height: 15),
                _imagen != null
                    ? Image.file(_imagen!, height: 150)
                    : const Text('Seleccione una imagen'),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_camera),
                  onPressed: _seleccionarImagen,
                  label: const Text('Seleccionar Imagen'),
                ),
                const SizedBox(height: 25),
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _enviar,
                        child: const Text('Enviar Denuncia'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
