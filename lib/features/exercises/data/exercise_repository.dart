import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/core/database/app_database.dart';
import 'package:gym_tracker/core/database/database_provider.dart';

import '../../../core/database/models/exercise_type.dart';

// Provider für das Repository selbst
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ExerciseRepository(db);
});

// Provider um ALLE Übungen zu laden (Live-Update dank Stream)
final exercisesStreamProvider = StreamProvider<List<Exercise>>((ref) {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.watchAllExercises();
});

class ExerciseRepository {
  final AppDatabase _db;

  ExerciseRepository(this._db);

  // Alle Übungen beobachten (Stream für Echtzeit-Updates)
  Stream<List<Exercise>> watchAllExercises() {
    return (_db.select(
      _db.exercises,
    )..orderBy([(t) => OrderingTerm(expression: t.name)])).watch();
  }

  // Eine Übung hinzufügen
  Future<int> addExercise(String name, String muscle, String equipment,
      ExerciseLogType logType) {
    return _db
        .into(_db.exercises)
        .insert(
          ExercisesCompanion.insert(
            name: name,
            targetMuscleGroup: Value(muscle),
            primaryEquipment: Value(equipment),
            isCustom: const Value(true),
            logType: logType,
          ),
        );
  }

  // Update einer existierenden Übung
  Future<bool> updateExercise(Exercise exercise) {
    // update(db.exercises).replace(exercise) ersetzt die Zeile komplett
    return _db.update(_db.exercises).replace(exercise);
  }

  // Löschen einer Übung
  Future<int> deleteExercise(int id) {
    return (_db.delete(_db.exercises)..where((t) => t.id.equals(id))).go();
  }

  // Neue Routine erstellen
  Future<int> createRoutine(String name, String description) {
    return _db
        .into(_db.routines)
        .insert(
          RoutinesCompanion.insert(name: name, description: Value(description)),
        );
  }

  // Übungen zu einer Routine hinzufügen
  Future<void> addExercisesToRoutine(
    int routineId,
    List<Exercise> exercises,
  ) async {
    await _db.batch((batch) {
      // Wir gehen durch die Liste und fügen sie mit Index ein
      for (int i = 0; i < exercises.length; i++) {
        batch.insert(
          _db.routineExercises,
          RoutineExercisesCompanion.insert(
            routineId: routineId,
            exerciseId: exercises[i].id,
            orderIndex: i, // WICHTIG für die Reihenfolge
          ),
        );
      }
    });
  }
}
