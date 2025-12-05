import 'package:flutter/material.dart';
import '../models/denuncia.dart';

class DetalleScreen extends StatelessWidget {
  final Denuncia denuncia;

  const DetalleScreen({super.key, required this.denuncia});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Detalle de Denuncia'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 3,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📸 Imagen principal
            if (denuncia.foto.isNotEmpty)
              Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    maxHeight: 400,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black12,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: InteractiveViewer(
                      clipBehavior: Clip.none,
                      panEnabled: true,
                      minScale: 0.8,
                      maxScale: 4.0,
                      child: Image.network(
                        "https://compossible-stephane-pesteringly.ngrok-free.dev/uploads/${denuncia.foto}",
                        fit: BoxFit.contain,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.broken_image,
                                size: 80, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Imagen no disponible'),
                          ],
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              )
            else
              Column(
                children: const [
                  Icon(Icons.image_not_supported,
                      size: 100, color: Colors.grey),
                  Text('Sin imagen disponible'),
                ],
              ),

            const SizedBox(height: 25),

            _campoTitulo(context, 'Descripción'),
            Text(denuncia.descripcion, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 15),

            _campoTitulo(context, 'Correo'),
            Text(denuncia.correo, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 15),

            _campoTitulo(context, 'Ubicación'),
            Text(
              denuncia.ubicacion.isNotEmpty
                  ? denuncia.ubicacion
                  : 'No especificada',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),

            _campoTitulo(context, 'Fecha de registro'),
            Text(denuncia.fecha, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _campoTitulo(BuildContext context, String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        titulo,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange.shade700,
              fontSize: 18,
            ),
      ),
    );
  }
}
