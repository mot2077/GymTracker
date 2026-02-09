import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/core/database/app_database.dart';
import 'package:gym_tracker/core/database/database_provider.dart';

// Model Helper: Eine Routine zusammen mit ihren Übungen
class RoutineWithExercises {
  final Routine routine;
  final List<Exercise> exercises;

  RoutineWithExercises({required this.routine, required this.exercises});
}

final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  return RoutineRepository(ref.watch(databaseProvider));
});

final routinesStreamProvider = StreamProvider<List<RoutineWithExercises>>((
  ref,
) {
  return ref.watch(routineRepositoryProvider).watchAllRoutines();
});

class RoutineRepository {
  final AppDatabase _db;

  RoutineRepository(this._db);

  // 1. Alle Routinen inklusive ihrer Übungen laden
  Stream<List<RoutineWithExercises>> watchAllRoutines() {
    // Das ist ein komplexer SQL Join, den Drift vereinfacht
    final query = _db.select(_db.routines).join([
      leftOuterJoin(
        _db.routineExercises,
        _db.routineExercises.routineId.equalsExp(_db.routines.id),
      ),
      leftOuterJoin(
        _db.exercises,
        _db.exercises.id.equalsExp(_db.routineExercises.exerciseId),
      ),
    ]);

    // Das Ergebnis ist eine Liste von "Rows", die wir gruppieren müssen
    return query.watch().map((rows) {
      final groupedData = <Routine, List<Exercise>>{};

      for (final row in rows) {
        final routine = row.readTable(_db.routines);
        final exercise = row.readTableOrNull(_db.exercises);
        final link = row.readTableOrNull(_db.routineExercises);

        // Map initialisieren
        if (!groupedData.containsKey(routine)) {
          groupedData[routine] = [];
        }

        // Übung hinzufügen, wenn vorhanden
        if (exercise != null) {
          groupedData[routine]!.add(exercise);
        }
      }

      // Umwandeln in unsere schöne Klasse
      return groupedData.entries.map((entry) {
        return RoutineWithExercises(routine: entry.key, exercises: entry.value);
      }).toList();
    });
  }

  // 2. Neue Routine erstellen
  Future<void> createRoutine({
    required String name,
    String? description,
    required List<Exercise> exercises,
  }) async {
    await _db.transaction(() async {
      // A. Routine einfügen
      final routineId = await _db
          .into(_db.routines)
          .insert(
            RoutinesCompanion.insert(
              name: name,
              description: Value(description),
            ),
          );

      // B. Verknüpfungen erstellen (Reihenfolge bewahren!)
      for (int i = 0; i < exercises.length; i++) {
        await _db
            .into(_db.routineExercises)
            .insert(
              RoutineExercisesCompanion.insert(
                routineId: routineId,
                exerciseId: exercises[i].id,
                orderIndex: i, // WICHTIG: Damit die Reihenfolge stimmt
              ),
            );
      }
    });
  }

  // 3. Routine löschen (Cascading delete regelt die Verknüpfungen)
  Future<void> deleteRoutine(int id) {
    return (_db.delete(_db.routines)..where((t) => t.id.equals(id))).go();
  }
}
