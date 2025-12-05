import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../services/biometric_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final BiometricService bioService = BiometricService();
  final AuthService authService = AuthService();

  bool loading = false;
  bool biometriaDisponible = false;
  bool verificandoBiometria = true;

  @override
  void initState() {
    super.initState();
    inicializar();
  }

  Future<void> inicializar() async {
    // Verificar si el dispositivo tiene biometría disponible
    final disponible = await bioService.hasEnrolledBiometrics();

    // Verificar si hay token guardado
    final token = await authService.leerToken();
    final hayTokenGuardado = token != null && token.isNotEmpty;

    setState(() {
      biometriaDisponible = disponible;
      verificandoBiometria = false;
    });

    // Si hay token Y biometría disponible, intentar login automático
    if (hayTokenGuardado && disponible) {
      await intentarLoginAutomatico();
    }
  }

  Future<void> intentarLoginAutomatico() async {
    final ok = await bioService.authenticate();

    if (ok && mounted) {
      // Validar que el token siga siendo válido
      final tokenValido = await validarToken();

      if (tokenValido) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        // Token expirado o inválido
        await authService.borrarToken();
        if (mounted) {
          _mostrarMensaje(
            "Sesión expirada. Ingresa nuevamente.",
            Colors.orange,
          );
        }
      }
    }
  }

  Future<void> loginConBiometria() async {
    final token = await authService.leerToken();

    if (token == null || token.isEmpty) {
      _mostrarMensaje(
        "No hay sesión guardada. Ingresa con usuario y contraseña.",
        Colors.redAccent,
      );
      return;
    }

    final ok = await bioService.authenticate();

    if (!ok) {
      _mostrarMensaje(
        "Autenticación biométrica cancelada",
        Colors.redAccent,
      );
      return;
    }

    // Validar que el token siga siendo válido
    setState(() => loading = true);
    final tokenValido = await validarToken();
    setState(() => loading = false);

    if (tokenValido && mounted) {
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      await authService.borrarToken();
      _mostrarMensaje(
        "Sesión expirada. Ingresa nuevamente.",
        Colors.orange,
      );
    }
  }

  Future<bool> validarToken() async {
    try {
      final token = await authService.leerToken();
      if (token == null) return false;

      final url = Uri.parse("http://192.168.18.60:5000/validate-token");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> login() async {
    if (userCtrl.text.trim().isEmpty || passCtrl.text.trim().isEmpty) {
      _mostrarMensaje("Completa todos los campos", Colors.redAccent);
      return;
    }

    setState(() => loading = true);

    final url = Uri.parse("http://192.168.18.60:5000/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user": userCtrl.text.trim(),
          "password": passCtrl.text.trim(),
        }),
      );

      setState(() => loading = false);

      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)["token"];
        await authService.guardarToken(token);

        if (mounted) {
          Navigator.pushReplacementNamed(context, "/home");
        }
      } else if (response.statusCode == 401) {
        _mostrarMensaje("Credenciales incorrectas", Colors.redAccent);
      } else {
        _mostrarMensaje(
          "Error del servidor: ${response.statusCode}",
          Colors.redAccent,
        );
      }
    } catch (e) {
      setState(() => loading = false);
      _mostrarMensaje("No hay conexión con la API", Colors.redAccent);
    }
  }

  void _mostrarMensaje(String msg, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Row(
          children: [
            Icon(
              color == Colors.redAccent ? Icons.error : Icons.info,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (verificandoBiometria) {
      return Scaffold(
        backgroundColor: Colors.deepOrange[50],
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.deepOrange,
              ),
              const SizedBox(height: 16),
              Text(
                "Verificando biometría...",
                style: TextStyle(
                  color: Colors.deepOrange[700],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.deepOrange[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icono
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepOrange.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.security,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 30),

                // Título
                const Text(
                  "Denuncias DUOC",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Ingresa a tu cuenta",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 40),

                // Card con formulario
                Card(
                  elevation: 8,
                  shadowColor: Colors.deepOrange.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Campo Usuario
                        TextField(
                          controller: userCtrl,
                          enabled: !loading,
                          decoration: InputDecoration(
                            labelText: "Usuario",
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: Colors.deepOrange,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.deepOrange,
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Campo Contraseña
                        TextField(
                          controller: passCtrl,
                          enabled: !loading,
                          obscureText: true,
                          onSubmitted: (_) => login(),
                          decoration: InputDecoration(
                            labelText: "Contraseña",
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Colors.deepOrange,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.deepOrange,
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Botón Ingresar
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: loading ? null : login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Ingresar",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        // Botón de Biometría (si está disponible)
                        if (biometriaDisponible) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey[400])),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "O",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey[400])),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: loading ? null : loginConBiometria,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Colors.deepOrange,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.fingerprint,
                                size: 28,
                                color: Colors.deepOrange,
                              ),
                              label: const Text(
                                "Ingresar con Biometría",
                                style: TextStyle(
                                  color: Colors.deepOrange,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Pie de página
                Text(
                  "Sistema de Denuncias DUOC UC",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    userCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }
}
