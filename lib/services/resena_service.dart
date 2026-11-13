import 'dart:convert';

import 'package:recetas_app/models/resena.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResenaService {
  String _keyForRecipe(int recetaId) => 'resenas_receta_$recetaId';

  Future<List<Resena>> obtenerResenas(int recetaId) async {
    final preferences = await SharedPreferences.getInstance();
    final storedResenas = preferences.getString(_keyForRecipe(recetaId));

    if (storedResenas == null) {
      return [];
    }

    final decoded = jsonDecode(storedResenas);
    if (decoded is! List) {
      throw const FormatException('El almacenamiento de reseñas no es válido.');
    }

    final resenas = decoded.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Una reseña almacenada no es válida.');
      }
      return Resena.fromJson(item);
    }).toList();
    resenas.sort((a, b) => b.fecha.compareTo(a.fecha));
    return resenas;
  }

  Future<List<Resena>> guardarResena(int recetaId, Resena resena) async {
    final resenas = await obtenerResenas(recetaId);
    resenas.insert(0, resena);

    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _keyForRecipe(recetaId),
      jsonEncode(resenas.map((item) => item.toJson()).toList()),
    );

    if (!saved) {
      throw StateError('No se pudo guardar la reseña en este dispositivo.');
    }

    return resenas;
  }
}
