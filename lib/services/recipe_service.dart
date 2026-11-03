import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:recetas_app/models/receta.dart';

class RecipeService {
  static const String _baseUrl = 'https://dummyjson.com/recipes';

  Future<List<Receta>> obtenerRecetas() async {
    final Uri url = Uri.parse(_baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final recipesJson = data['recipes'];

      if (recipesJson is! List) {
        return const [];
      }

      return recipesJson
          .map((recetaJson) => Receta.fromJson(recetaJson as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Error al obtener las recetas: ${response.statusCode}');
  }
}