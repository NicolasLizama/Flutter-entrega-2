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
  final api = ApiService();

  Future<void> _obtenerUbicacionActual() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activa tu GPS para continuar')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _ubicacionCtrl.text = '${pos.latitude}, ${pos.longitude}';
    });
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _imagen = File(picked.path));
    }
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate() || _imagen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    setState(() => _loading = true);

    final ok = await api.crearDenuncia(
      _correoCtrl.text.trim(),
      _descCtrl.text.trim(),
      _ubicacionCtrl.text.trim(),
      _imagen!,
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al enviar denuncia")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nueva Denuncia"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _correoCtrl,
                decoration: const InputDecoration(labelText: "Correo"),
              ),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: "Descripción"),
              ),
              TextFormField(
                controller: _ubicacionCtrl,
                decoration: const InputDecoration(labelText: "Ubicación"),
              ),
              ElevatedButton(
                onPressed: _obtenerUbicacionActual,
                child: const Text("Obtener ubicación actual"),
              ),
              const SizedBox(height: 10),
              _imagen != null
                  ? Image.file(_imagen!, height: 150)
                  : const Text("Seleccione una imagen"),
              ElevatedButton(
                onPressed: _seleccionarImagen,
                child: const Text("Seleccionar imagen"),
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _enviar,
                      child: const Text("Enviar"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
