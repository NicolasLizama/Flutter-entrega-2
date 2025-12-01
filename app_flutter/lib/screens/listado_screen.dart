import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/api_service.dart';
import 'detalle_screen.dart';

class ListadoScreen extends StatefulWidget {
  const ListadoScreen({super.key});

  @override
  State<ListadoScreen> createState() => ListadoScreenState();
}

class ListadoScreenState extends State<ListadoScreen> {
  late Future<List<Denuncia>> _denuncias;

  @override
  void initState() {
    super.initState();
    _denuncias = ApiService.getDenuncias();
  }

  // 🔄 Método público para refrescar desde main.dart
  void recargarDenuncias() {
    setState(() {
      _denuncias = ApiService.getDenuncias();
    });
  }

  // 🔁 Permite actualizar manualmente con "pull to refresh"
  Future<void> _refrescarManual() async {
    recargarDenuncias();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Listado de Denuncias ."),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 3,
      ),
      body: FutureBuilder<List<Denuncia>>(
        future: _denuncias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "❌ Error al cargar denuncias: ${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No hay denuncias registradas, haz una",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final denuncias = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refrescarManual,
            color: Colors.deepOrange,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: denuncias.length,
              itemBuilder: (context, index) {
                final d = denuncias[index];

                return Card(
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '${ApiService.baseUrl}/../uploads/${d.foto}',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 40),
                      ),
                    ),
                    title: Text(
                      d.descripcion,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      "${d.correo}\n${d.ubicacion}",
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    isThreeLine: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalleScreen(denuncia: d),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
