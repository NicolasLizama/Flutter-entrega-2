class Denuncia {
  final int id;
  final String correo;
  final String descripcion;
  final String ubicacion;
  final String foto;
  final String fecha;

  Denuncia({
    required this.id,
    required this.correo,
    required this.descripcion,
    required this.ubicacion,
    required this.foto,
    required this.fecha,
  });

  factory Denuncia.fromJson(Map<String, dynamic> json) {
    return Denuncia(
      id: json['id'],
      correo: json['correo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      ubicacion: json['ubicacion'] ?? '',
      foto: json['foto'] ?? '',
      fecha: json['fecha'] ?? '',
    );
  }
}
