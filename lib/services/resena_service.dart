import 'dart:convert';

import 'package:path/path.dart';
import 'package:recetas_app/models/resena.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class ResenaService {
  static const _legacyPrefix = 'resenas_receta_';
  static const _migrationKey = 'shared_preferences_reviews';

  Future<Database>? _databaseFuture;

  Future<Database> get _database => _databaseFuture ??= _openDatabase();

  Future<Database> _openDatabase() async {
    final databasePath = join(await getDatabasesPath(), 'recetas_app.db');
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE resenas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            receta_id INTEGER NOT NULL,
            autor TEXT NOT NULL,
            comentario TEXT NOT NULL,
            calificacion INTEGER NOT NULL,
            fecha TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE migraciones (
            clave TEXT PRIMARY KEY,
            valor TEXT NOT NULL
          )
        ''');
      },
    );

    await _migrarResenasAnteriores(database);
    return database;
  }

  Future<void> _migrarResenasAnteriores(Database database) async {
    final preferences = await SharedPreferences.getInstance();
    final legacyKeys = preferences
        .getKeys()
        .where((key) => key.startsWith(_legacyPrefix))
        .toList();

    await database.transaction((transaction) async {
      final migration = await transaction.query(
        'migraciones',
        where: 'clave = ?',
        whereArgs: [_migrationKey],
        limit: 1,
      );
      if (migration.isNotEmpty) {
        return;
      }

      for (final key in legacyKeys) {
        final recetaId = int.tryParse(key.substring(_legacyPrefix.length));
        final storedReviews = preferences.getString(key);
        if (recetaId == null || storedReviews == null) {
          throw const FormatException(
            'Una reseña almacenada anteriormente no es válida.',
          );
        }

        final decoded = jsonDecode(storedReviews);
        if (decoded is! List) {
          throw const FormatException(
            'El almacenamiento anterior de reseñas no es válido.',
          );
        }

        for (final item in decoded) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException(
              'Una reseña almacenada anteriormente no es válida.',
            );
          }
          final review = Resena.fromJson(item);
          await transaction.insert('resenas', {
            'receta_id': recetaId,
            ..._toDatabaseRow(review),
          });
        }
      }

      await transaction.insert('migraciones', {
        'clave': _migrationKey,
        'valor': 'completada',
      });
    });

    for (final key in legacyKeys) {
      if (!await preferences.remove(key)) {
        throw StateError('No se pudo completar la migración de las reseñas.');
      }
    }
  }

  Map<String, Object?> _toDatabaseRow(Resena resena) => {
    'autor': resena.autor,
    'comentario': resena.comentario,
    'calificacion': resena.calificacion,
    'fecha': resena.fecha.toIso8601String(),
  };

  Resena _fromDatabaseRow(Map<String, Object?> row) => Resena(
    autor: row['autor']! as String,
    comentario: row['comentario']! as String,
    calificacion: row['calificacion']! as int,
    fecha: DateTime.parse(row['fecha']! as String),
  );

  Future<List<Resena>> obtenerResenas(int recetaId) async {
    final database = await _database;
    final rows = await database.query(
      'resenas',
      where: 'receta_id = ?',
      whereArgs: [recetaId],
      orderBy: 'fecha DESC, id DESC',
    );
    return rows.map(_fromDatabaseRow).toList();
  }

  Future<List<Resena>> guardarResena(int recetaId, Resena resena) async {
    final database = await _database;
    await database.insert('resenas', {
      'receta_id': recetaId,
      ..._toDatabaseRow(resena),
    });
    return obtenerResenas(recetaId);
  }
}
