import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/core/database/app_database.dart';
import 'package:gym_tracker/core/database/database_provider.dart';

// Hilfsklasse für die UI: Eine Übung innerhalb einer Routine (+ Settings wie Sätze)
class RoutineExerciseData {
  final Exercise exercise;
  final int sets;

  RoutineExerciseData({required this.exercise, this.sets = 1});

  // CopyWith für einfache Updates
  RoutineExerciseData copyWith({Exercise? exercise, int? sets}) {
    return RoutineExerciseData(
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
    );
  }
}

class RoutineWithExercises {
  final Routine routine;
  final List<RoutineExerciseData> exercises; // Typ geändert!

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

  // 1. Alle Routinen laden (angepasst auf neue Struktur)
  Stream<List<RoutineWithExercises>> watchAllRoutines() {
    final query = _db.select(_db.routines).join([
      leftOuterJoin(
        _db.routineExercises,
        _db.routineExercises.routineId.equalsExp(_db.routines.id),
      ),
      leftOuterJoin(
        _db.exercises,
        _db.exercises.id.equalsExp(_db.routineExercises.exerciseId),
      ),
    ])
      ..orderBy([
        OrderingTerm.asc(_db.routineExercises.orderIndex)
      ]); // Wichtig: Sortierung!

    return query.watch().map((rows) {
      final groupedData = <Routine, List<RoutineExerciseData>>{};

      for (final row in rows) {
        final routine = row.readTable(_db.routines);
        final exercise = row.readTableOrNull(_db.exercises);
        final link = row.readTableOrNull(_db.routineExercises);

        if (!groupedData.containsKey(routine)) {
          groupedData[routine] = [];
        }

        if (exercise != null && link != null) {
          // Hier lesen wir jetzt auch die 'sets' aus der Verknüpfungstabelle
          groupedData[routine]!.add(
            RoutineExerciseData(exercise: exercise, sets: link.sets),
          );
        }
      }

      return groupedData.entries.map((entry) {
        return RoutineWithExercises(routine: entry.key, exercises: entry.value);
      }).toList();
    });
  }

  // 2. Erstellen (CREATE)
  Future<void> createRoutine({
    required String name,
    String? description,
    required List<RoutineExerciseData> exercises,
  }) async {
    await _db.transaction(() async {
      final routineId = await _db.into(_db.routines).insert(
        RoutinesCompanion.insert(name: name, description: Value(description)),
      );

      await _insertRoutineExercises(routineId, exercises);
    });
  }

  // 3. Aktualisieren (UPDATE) - Erhält die Routine-ID!
  Future<void> updateRoutine({
    required int routineId,
    required String name,
    String? description,
    required List<RoutineExerciseData> exercises,
  }) async {
    await _db.transaction(() async {
      // A. Stammdaten updaten
      await (_db.update(_db.routines)
        ..where((t) => t.id.equals(routineId))).write(
        RoutinesCompanion(
          name: Value(name),
          description: Value(description),
        ),
      );

      // B. Alte Verknüpfungen löschen (Clean Slate für die Übungsliste)
      // Das ist sicher, da wir nur die Verknüpfung löschen, nicht die Übungen selbst.
      await (_db.delete(_db.routineExercises)
        ..where((t) => t.routineId.equals(routineId))).go();

      // C. Neue Verknüpfungen einfügen (mit neuer Reihenfolge und Sets)
      await _insertRoutineExercises(routineId, exercises);
    });
  }

  // Helper zum Einfügen der Übungen
  Future<void> _insertRoutineExercises(int routineId,
      List<RoutineExerciseData> exercises) async {
    for (int i = 0; i < exercises.length; i++) {
      final data = exercises[i];
      await _db.into(_db.routineExercises).insert(
        RoutineExercisesCompanion.insert(
          routineId: routineId,
          exerciseId: data.exercise.id,
          orderIndex: i,
          sets: Value(data.sets), // Sets speichern!
        ),
      );
    }
  }

  Future<void> deleteRoutine(int id) {
    return (_db.delete(_db.routines)..where((t) => t.id.equals(id))).go();
  }
}
