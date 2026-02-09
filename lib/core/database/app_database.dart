import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:gym_tracker/core/database/initial_data.dart';
import 'package:gym_tracker/core/database/models/exercise_type.dart';
import 'package:gym_tracker/core/database/tables.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart'; // Generieren durch dart run build_runner build --delete-conflicting-outputs

@DriftDatabase(
  tables: [Exercises, Routines, RoutineExercises, Workouts, WorkoutSets],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1; // Bei Tabellenänderungen erhöhen und Migration anpassen

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await batch((batch) {
          batch.insertAll(exercises, getInitialExercises());
        });
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Wir fügen die neuen Spalten hinzu
          await m.addColumn(exercises, exercises.logType);
          await m.addColumn(workoutSets, workoutSets.durationInSeconds);
          await m.addColumn(workoutSets, workoutSets.distanceInKm);
          await m.addColumn(workoutSets, workoutSets.calories);
        }
      },
    );
  }
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
