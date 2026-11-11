import 'package:flutter/material.dart';
import 'package:recetas_app/models/receta.dart'; 
import 'package:recetas_app/services/recipe_service.dart';
import 'package:recetas_app/widgets/recetas_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Receta>> _recetasFuture;

  @override
  void initState() {
    super.initState();
    _recetasFuture = RecipeService().obtenerRecetas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetas'),
      ),
      body: FutureBuilder<List<Receta>>(
        future: _recetasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron recetas.'));
          } else {
            final recetas = snapshot.data!;
            return ListView.builder(
              itemCount: recetas.length,
              itemBuilder: (context, index) {
                final receta = recetas[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detalle',
                      arguments: receta,
                    );
                  },
                  child: RecetaCard(receta: receta),
                );
              },
            );
          }
        },
      ),
    );
  }
}
