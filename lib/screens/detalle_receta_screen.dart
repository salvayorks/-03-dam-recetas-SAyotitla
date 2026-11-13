import 'package:flutter/material.dart';
import 'package:recetas_app/models/receta.dart';
import 'package:recetas_app/models/resena.dart';
import 'package:recetas_app/services/resena_service.dart';

class DetalleRecetaScreen extends StatefulWidget {
  final Receta receta;

  const DetalleRecetaScreen({super.key, required this.receta});

  @override
  State<DetalleRecetaScreen> createState() => _DetalleRecetaScreenState();
}

class _DetalleRecetaScreenState extends State<DetalleRecetaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _autorController = TextEditingController();
  final _comentarioController = TextEditingController();
  final _resenaService = ResenaService();
  late Future<List<Resena>> _resenasFuture;
  int _calificacion = 5;
  bool _guardandoResena = false;

  @override
  void initState() {
    super.initState();
    _cargarResenas();
  }

  @override
  void dispose() {
    _autorController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  void _cargarResenas() {
    _resenasFuture = _resenaService.obtenerResenas(widget.receta.id);
  }

  Future<void> _guardarResena() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _guardandoResena = true);
    try {
      final resenas = await _resenaService.guardarResena(
        widget.receta.id,
        Resena(
          autor: _autorController.text.trim(),
          comentario: _comentarioController.text.trim(),
          calificacion: _calificacion,
          fecha: DateTime.now(),
        ),
      );

      if (!mounted) return;
      setState(() {
        _resenasFuture = Future.value(resenas);
        _autorController.clear();
        _comentarioController.clear();
        _calificacion = 5;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reseña guardada correctamente.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la reseña: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _guardandoResena = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final receta = widget.receta;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de la receta')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              receta.imagenUrl,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/receta_placeholder.png',
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ingredientes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...receta.ingredientes.map(
            (ingrediente) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(child: Text(ingrediente)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Preparación',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...receta.instrucciones.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.deepOrange,
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(entry.value)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Reseñas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _autorController,
                  decoration: const InputDecoration(
                    labelText: 'Tu nombre',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Escribe tu nombre.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _comentarioController,
                  decoration: const InputDecoration(
                    labelText: 'Escribe tu reseña',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 3,
                  maxLines: 5,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Escribe un comentario.'
                      : null,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Calificación:'),
                    const SizedBox(width: 8),
                    ...List.generate(
                      5,
                      (index) => IconButton(
                        tooltip: '${index + 1} estrellas',
                        onPressed: _guardandoResena
                            ? null
                            : () => setState(() => _calificacion = index + 1),
                        icon: Icon(
                          index < _calificacion
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _guardandoResena ? null : _guardarResena,
                  icon: _guardandoResena
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _guardandoResena ? 'Guardando...' : 'Guardar reseña',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Resena>>(
            future: _resenasFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No se pudieron cargar las reseñas: ${snapshot.error}',
                    ),
                    TextButton(
                      onPressed: () => setState(_cargarResenas),
                      child: const Text('Intentar de nuevo'),
                    ),
                  ],
                );
              }

              final resenas = snapshot.data ?? const <Resena>[];
              if (resenas.isEmpty) {
                return const Text('Aún no hay reseñas. ¡Escribe la primera!');
              }

              return Column(
                children: resenas
                    .map(
                      (resena) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(resena.autor),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    index < resena.calificacion
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 18,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(resena.comentario),
                              const SizedBox(height: 4),
                              Text(
                                '${resena.fecha.toLocal().day.toString().padLeft(2, '0')}/'
                                '${resena.fecha.toLocal().month.toString().padLeft(2, '0')}/'
                                '${resena.fecha.toLocal().year}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
