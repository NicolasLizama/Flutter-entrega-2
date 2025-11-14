import 'package:flutter/material.dart';
import 'screens/listado_screen.dart';
import 'screens/nueva_denuncia_screen.dart';

void main() {
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

  // ✅ Clave para controlar la recarga del ListadoScreen
  final GlobalKey<ListadoScreenState> _listadoKey =
      GlobalKey<ListadoScreenState>();

  // ==============================
  // 🔹 Control de pestañas / navegación si eso
  // ==============================
  void _onItemTapped(int index) async {
    if (index == 1) {
      // Abre pantalla de nueva denuncia con animación
      final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const NuevaDenunciaScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );

      // Si la denuncia fue enviada, recargar listado
      if (result == true && _listadoKey.currentState != null) {
        _listadoKey.currentState!.recargarDenuncias();
      }
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  // ==============================
  // 🧱 Construcción UI principal
  // ==============================
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
          const SizedBox(), // “Nueva” no tiene vista directa, se abre con Navigator
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
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepOrange,
        onTap: _onItemTapped,
      ),
    );
  }
}
