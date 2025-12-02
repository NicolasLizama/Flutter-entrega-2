import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';
import 'screens/listado_screen.dart';
import 'screens/nueva_denuncia_screen.dart';
import 'screens/crear_user.dart';
import 'screens/login.dart';
import 'services/api_service.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await ScreenProtector.preventScreenshotOn();
  }

  runApp(const DenunciasApp());
}

class DenunciasApp extends StatefulWidget {
  const DenunciasApp({super.key});

  @override
  State<DenunciasApp> createState() => _DenunciasAppState();
}

class _DenunciasAppState extends State<DenunciasApp> {
  bool _loading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final token = await ApiService.getToken();
    setState(() {
      _isLoggedIn = token != null;
      _loading = false;
    });
  }

  void _onLoginSuccess() {
    setState(() => _isLoggedIn = true);
  }

  void _onLogout() async {
    await ApiService.logout();
    setState(() {
      _isLoggedIn = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Has cerrado sesión')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Denuncias DUOC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: _isLoggedIn
          ? HomePage(onLogout: _onLogout)
          : LoginScreen(onLoginSuccess: _onLoginSuccess),
    );
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback onLogout;
  const HomePage({super.key, required this.onLogout});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final GlobalKey<ListadoScreenState> _listadoKey =
      GlobalKey<ListadoScreenState>();

  void _onItemTapped(int index) async {
    if (index == 1) {
      // 🔑 Verificamos token antes de abrir NuevaDenunciaScreen
      final token = await ApiService.getToken();
      if (token == null) {
        setState(() => _selectedIndex = 3); // Mostrar login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para crear una denuncia'),
          ),
        );
        return;
      }

      // Token válido -> abrir pantalla
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
    } else if (index == 3) {
      // Mostrar Login solo si NO hay token
      final token = await ApiService.getToken();
      if (token == null) {
        setState(() => _selectedIndex = 3); // LoginScreen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ya has iniciado sesión')),
        );
      }
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  void _onLoginSuccess() {
    setState(() => _selectedIndex = 0); // Volver a ListadoScreen tras login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Denuncias DUOC'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          ListadoScreen(key: _listadoKey),               // 0 -> Listado
          const SizedBox(),                               // 1 -> NuevaDenuncia (navegación)
          const CrearUserScreen(),                        // 2 -> Crear usuario
          LoginScreen(onLoginSuccess: _onLoginSuccess),  // 3 -> Login
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
