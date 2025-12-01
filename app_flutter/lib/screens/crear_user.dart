import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CrearUserScreen extends StatefulWidget {
  const CrearUserScreen({super.key});

  @override
  State<CrearUserScreen> createState() => _CrearUserScreenState();
}

class _CrearUserScreenState extends State<CrearUserScreen> {
  final _formKey = GlobalKey<FormState>();

  final _correoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;

  // ============================
  // 🚀 ENVIAR FORMULARIO A API
  // ============================
  Future<void> _crearUsuario() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor complete todos los campos")),
      );
      return;
    }

    setState(() => _loading = true);

    final ok = await ApiService.crearUsuario(
      _correoCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(true);

      Future.delayed(const Duration(milliseconds: 300), () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Usuario creado correctamente"),
            backgroundColor: Colors.green,
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al crear usuario"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================
  // 🧱 UI
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Usuario"),
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
                  decoration: const InputDecoration(labelText: "Correo"),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Ingrese un correo" : null,
                ),

                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Contraseña"),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Ingrese una contraseña" : null,
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
                        onPressed: _crearUsuario,
                        child: const Text("Crear Usuario"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
