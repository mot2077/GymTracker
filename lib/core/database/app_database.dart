import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:gym_tracker/core/database/tables.dart'; // Importiere deine Tabellen
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// WICHTIG: Dieser Part `part 'app_database.g.dart';` wird rot unterkringelt sein.
// Das ist normal! Die Datei existiert noch nicht, wir generieren sie gleich.
part 'app_database.g.dart';

@DriftDatabase(
  tables: [Exercises, Routines, RoutineExercises, Workouts, WorkoutSets],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1; // Wenn du Tabellen änderst, musst du das hochzählen
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Holen uns den Ordner, wo die App Dateien speichern darf
    final dbFolder = await getApplicationDocumentsDirectory();
    // Erstellen die Datei 'db.sqlite'
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    // Öffnen die Datenbank
    return NativeDatabase.createInBackground(file);
  });
}
