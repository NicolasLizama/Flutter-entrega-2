import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';
import 'screens/listado_screen.dart';
import 'screens/nueva_denuncia_screen.dart';
import 'screens/crear_user.dart';
import 'screens/login.dart';

import 'package:flutter/foundation.dart'; // esto para que pueda seguir ejecutando DEV: lizama

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Evitar usar ScreenProtector en Web
  if (!kIsWeb) {
    await ScreenProtector.preventScreenshotOn();
  }

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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Clave para refrescar el listado
  final GlobalKey<ListadoScreenState> _listadoKey =
      GlobalKey<ListadoScreenState>();

  // Control de navegación
  void _onItemTapped(int index) async {
    if (index == 1) {
      // Nueva denuncia
      final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const NuevaDenunciaScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );

      if (result == true && _listadoKey.currentState != null) {
        _listadoKey.currentState!.recargarDenuncias();
      }

    } else if (index == 2) {
      // Crear usuario
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CrearUserScreen()),
      );

    } else if (index == 3) {
      // Login
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );

    } else {
      // Listado
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Denuncias DUOC'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          ListadoScreen(key: _listadoKey),
          const SizedBox(), // nada; otras pantallas usan Navigator
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Listado',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Nueva',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Crear',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Login',
          ),
        ],

        currentIndex: _selectedIndex,

        // ✔ Mostrar labels siempre
        showSelectedLabels: true,
        showUnselectedLabels: true,

        // ✔ Iconos naranjos
        selectedItemColor: Colors.deepOrange,
        selectedIconTheme: IconThemeData(color: Colors.deepOrange),
        unselectedItemColor: Colors.deepOrangeAccent,
        unselectedIconTheme: IconThemeData(color: Colors.deepOrangeAccent),

        onTap: _onItemTapped,
      ),
    );
  }
}
