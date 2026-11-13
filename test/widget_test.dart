import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recetas_app/main.dart';
import 'package:recetas_app/models/receta.dart';
import 'package:recetas_app/models/resena.dart';
import 'package:recetas_app/screens/detalle_receta_screen.dart';
import 'package:recetas_app/services/resena_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows the splash screen when the app starts', (tester) async {
    await tester.pumpWidget(const RecetasApp());

    expect(find.text('Recetas App'), findsOneWidget);
    expect(find.text('Sabores del Mayab'), findsOneWidget);
  });

  test('parses recipe fields from DummyJSON', () {
    final receta = Receta.fromJson({
      'id': 1,
      'name': 'Sopa de prueba',
      'ingredients': ['agua', 'sal'],
      'instructions': ['Mezclar'],
      'prepTimeMinutes': 10,
      'cookTimeMinutes': 20,
      'caloriesPerServing': 150,
      'image': 'https://example.com/receta.jpg',
      'rating': 4.5,
    });

    expect(receta.nombre, 'Sopa de prueba');
    expect(receta.totalTime, 30);
    expect(receta.calificacion, 4.5);
    expect(receta.imagenUrl, 'https://example.com/receta.jpg');
  });

  test('saves reviews separately for each recipe', () async {
    SharedPreferences.setMockInitialValues({});
    final service = ResenaService();
    final resena = Resena(
      autor: 'Ana',
      comentario: 'Muy rica',
      calificacion: 4,
      fecha: DateTime(2026, 11, 13),
    );

    await service.guardarResena(1, resena);

    final storedResenas = await ResenaService().obtenerResenas(1);
    expect(storedResenas, hasLength(1));
    expect(storedResenas.single.autor, resena.autor);
    expect(storedResenas.single.comentario, resena.comentario);
    expect(storedResenas.single.calificacion, resena.calificacion);
    expect(storedResenas.single.fecha, resena.fecha);
    expect(await service.obtenerResenas(2), isEmpty);
  });

  testWidgets('saves and displays a review in the recipe detail', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    SharedPreferences.setMockInitialValues({});
    final receta = Receta(
      id: 3,
      nombre: 'Receta de prueba',
      ingredientes: const ['Agua'],
      instrucciones: const ['Mezclar'],
      tiempoPreparacion: 5,
      tiempoCoccion: 10,
      calorias: 100,
      imagenUrl: 'https://example.com/receta.jpg',
      calificacion: 4.5,
    );

    await tester.pumpWidget(
      MaterialApp(home: DetalleRecetaScreen(receta: receta)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Ana');
    await tester.enterText(find.byType(TextFormField).at(1), 'Muy rica');
    await tester.ensureVisible(find.byTooltip('4 estrellas'));
    await tester.tap(find.byTooltip('4 estrellas'));
    await tester.ensureVisible(find.text('Guardar reseña'));
    await tester.tap(find.text('Guardar reseña'));
    await tester.pumpAndSettle();

    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Muy rica'), findsOneWidget);
    expect(await ResenaService().obtenerResenas(receta.id), hasLength(1));
  });
}
