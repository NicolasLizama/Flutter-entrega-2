import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';
import 'screens/listado_screen.dart';
import 'screens/nueva_denuncia_screen.dart';
import 'screens/crear_user.dart';
import 'screens/login.dart';

import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  final GlobalKey<ListadoScreenState> _listadoKey =
      GlobalKey<ListadoScreenState>();

  void _onItemTapped(int index) async {
    if (index == 1) {
      // Nueva denuncia sigue usando Navigator
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
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  void _onLoginSuccess() {
    setState(() => _selectedIndex = 0); // Muestra ListadoScreen
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
          ListadoScreen(key: _listadoKey),               // 0
          const SizedBox(),                               // 1 -> NuevaDenuncia
          const CrearUserScreen(),                        // 2
          LoginScreen(onLoginSuccess: _onLoginSuccess),  // 3
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Listado'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Nueva'),
          BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Crear'),
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Login'),
        ],
        currentIndex: _selectedIndex,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: Colors.deepOrange,
        selectedIconTheme: const IconThemeData(color: Colors.deepOrange),
        unselectedItemColor: Colors.deepOrangeAccent,
        unselectedIconTheme: const IconThemeData(color: Colors.deepOrangeAccent),
        onTap: _onItemTapped,
      ),
    );
  }
}
