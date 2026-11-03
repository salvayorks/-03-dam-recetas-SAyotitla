import 'package:flutter/material.dart';
import 'package:recetas_app/models/receta.dart';
import 'package:recetas_app/services/recipe_service.dart';
import 'package:recetas_app/widgets/receta_card.dart';

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
      backgroundColor: const Color(0xFFEDECEC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEDECEC),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Recetas',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Receta>>(
        future: _recetasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron recetas.'));
          }

          final recetas = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListView.builder(
                itemCount: recetas.length,
                itemBuilder: (context, index) {
                  final receta = recetas[index];
                  return RecetaCard(
                    receta: receta,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/detalle',
                        arguments: receta,
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
