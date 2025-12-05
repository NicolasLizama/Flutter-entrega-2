import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'screens/listado_screen.dart';
import 'screens/nueva_denuncia_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DenunciasApp());
}

class DenunciasApp extends StatelessWidget {
  const DenunciasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Denuncias DUOC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      initialRoute: "/login",
      routes: {
        "/login": (_) => const LoginScreen(),
        "/home": (_) => const HomeScreen(),
        "/listado": (_) => const ListadoScreen(),
        "/nueva": (_) => const NuevaDenunciaScreen(),
      },
    );
  }
}
