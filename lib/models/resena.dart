class Resena {
  final String autor;
  final String comentario;
  final int calificacion;
  final DateTime fecha;

  const Resena({
    required this.autor,
    required this.comentario,
    required this.calificacion,
    required this.fecha,
  });

  Map<String, dynamic> toJson() => {
    'autor': autor,
    'comentario': comentario,
    'calificacion': calificacion,
    'fecha': fecha.toIso8601String(),
  };

  factory Resena.fromJson(Map<String, dynamic> json) {
    final autor = json['autor'];
    final comentario = json['comentario'];
    final calificacion = json['calificacion'];
    final fecha = json['fecha'];

    if (autor is! String ||
        comentario is! String ||
        calificacion is! int ||
        fecha is! String) {
      throw const FormatException('Los datos de la reseña no son válidos.');
    }

    return Resena(
      autor: autor,
      comentario: comentario,
      calificacion: calificacion,
      fecha: DateTime.parse(fecha),
    );
  }
}
