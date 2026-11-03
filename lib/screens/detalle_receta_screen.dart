import 'package:flutter/material.dart';
import 'package:recetas_app/models/receta.dart';

class DetalleRecetaScreen extends StatelessWidget {
  final Receta receta;

  const DetalleRecetaScreen({
    super.key,
    required this.receta,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receta.nombre),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                receta.imagenUrl,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 6),
                Text(receta.calificacion.toStringAsFixed(1)),
                const SizedBox(width: 16),
                const Icon(Icons.timer),
                const SizedBox(width: 6),
                Text('${receta.totalTime} min'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Ingredientes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...receta.ingredientes.map(
              (ingrediente) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(ingrediente)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Preparación',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...receta.instrucciones.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${entry.key + 1}. ${entry.value}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}