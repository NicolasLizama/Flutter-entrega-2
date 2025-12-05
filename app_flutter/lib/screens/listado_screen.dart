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
  final ApiService api = ApiService();

  @override
  void initState() {
    super.initState();
    _denuncias = api.getDenuncias();
  }

  void recargarDenuncias() {
    setState(() {
      _denuncias = api.getDenuncias();
    });
  }

  Future<void> _refrescarManual() async {
    recargarDenuncias();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // ❌❌❌ IMPORTANTE: ESTE APPBAR SE ELIMINA
      // appBar: AppBar(...)

      body: FutureBuilder<List<Denuncia>>(
        future: _denuncias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("❌ Error: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No hay denuncias registradas"),
            );
          }

          final denuncias = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refrescarManual,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: denuncias.length,
              itemBuilder: (context, index) {
                final d = denuncias[index];

                return Card(
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        "https://compossible-stephane-pesteringly.ngrok-free.dev/uploads/${d.foto}",
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      ),
                    ),
                    title: Text(
                      d.descripcion,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${d.correo}\n${d.ubicacion}"),
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
