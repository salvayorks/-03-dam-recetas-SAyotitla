class Receta {
  final int id;
  final String nombre;
  final List<String> ingredientes;
  final List<String> instrucciones;
  final int tiempoPreparacion;
  final int tiempoCoccion;
  final int calorias;
  final String imagenUrl;
  final double calificacion;

  Receta({
    required this.id,
    required this.nombre,
    required this.ingredientes,
    required this.instrucciones,
    required this.tiempoPreparacion,
    required this.tiempoCoccion,
    required this.calorias,
    required this.imagenUrl,
    required this.calificacion,
  });

  factory Receta.fromJson(Map<String, dynamic> json) {
    final ingredientes = json['ingredients'];
    final instrucciones = json['instructions'];

    return Receta(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nombre: json['name'] is String ? json['name'] as String : 'Sin nombre',
      ingredientes: ingredientes is List
          ? ingredientes.map((item) => item.toString()).toList()
          : const [],
      instrucciones: instrucciones is List
          ? instrucciones.map((item) => item.toString()).toList()
          : const [],
      tiempoPreparacion: (json['prepTimeMinutes'] as num?)?.toInt() ?? 0,
      tiempoCoccion: (json['cookTimeMinutes'] as num?)?.toInt() ??
          (json['cookingMinutes'] as num?)?.toInt() ??
          0,
      calorias: (json['caloriesPerServing'] as num?)?.toInt() ?? 0,
      imagenUrl: json['image'] is String
          ? json['image'] as String
          : (json['imageUrl'] as String?) ?? '',
      calificacion:
          ((json['rating'] ?? json['calificacion']) as num?)?.toDouble() ?? 0,
    );
  }

  int get totalTime => tiempoPreparacion + tiempoCoccion;
}
