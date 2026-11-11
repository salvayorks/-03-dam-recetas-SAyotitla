import 'package:flutter/material.dart';
import 'package:recetas_app/models/receta.dart';
import 'package:recetas_app/screens/detalle_receta_screen.dart';
import 'package:recetas_app/screens/home_screen.dart';
import 'package:recetas_app/screens/splash_screen.dart';

void main() {
  runApp(const RecetasApp());
}

class RecetasApp extends StatelessWidget {
  const RecetasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recetas App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/detalle': (context) {
          final receta = ModalRoute.of(context)!.settings.arguments as Receta;
          return DetalleRecetaScreen(receta: receta);
        },
      },
    );
  }
}
