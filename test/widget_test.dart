import 'package:flutter_test/flutter_test.dart';
import 'package:recetas_app/main.dart';
import 'package:recetas_app/models/receta.dart';

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
}
