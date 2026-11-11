import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:recetas_app/models/receta.dart';

class RecipeService {
  static const String _baseUrl = 'https://dummyjson.com/recipes';

  Future<List<Receta>> obtenerRecetas() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode != 200) {
      throw Exception('Error al obtener las recetas: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final recipesJson = data['recipes'];
    if (recipesJson is! List) {
      throw const FormatException('La respuesta no contiene una lista de recetas.');
    }

    return recipesJson
        .map((recipeJson) => Receta.fromJson(recipeJson as Map<String, dynamic>))
        .toList();
  }
}
