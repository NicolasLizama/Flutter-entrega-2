import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';
import '../services/auth_service.dart';
import 'package:action_figures_app/screens/listado_screen.dart';
import 'package:action_figures_app/screens/nueva_denuncia_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final GlobalKey<ListadoScreenState> _listadoKey =
      GlobalKey<ListadoScreenState>();

  @override
  void initState() {
    super.initState();
    ScreenProtector.preventScreenshotOn();
  }

  @override
  void dispose() {
    ScreenProtector.preventScreenshotOff();
    super.dispose();
  }

  Future<void> logout() async {
    await AuthService().borrarToken();

    Navigator.pushNamedAndRemoveUntil(
      context,
      "/login",
      (route) => false,
    );
  }

  void _onItemTapped(int index) async {
    if (index == 1) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NuevaDenunciaScreen()),
      );

      if (result == true && _listadoKey.currentState != null) {
        _listadoKey.currentState!.recargarDenuncias();
      }
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Denuncias DUOC"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar sesión",
            onPressed: logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          ListadoScreen(key: _listadoKey), // ⬅ LISTADO DENUNCIAS
          const SizedBox(), // ⬅ Placeholder crear denuncia
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Listado",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: "Nueva Denuncia",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepOrange,
        onTap: _onItemTapped,
      ),
    );
  }
}
