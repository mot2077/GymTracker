import 'package:drift/drift.dart';

// 1. Der Katalog aller möglichen Übungen
class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  TextColumn get targetMuscleGroup =>
      text().nullable()(); // z.B. "Chest", "Legs"
  TextColumn get primaryEquipment =>
      text().nullable()(); // z.B. "Barbell", "Dumbbell"
  BoolColumn get isCustom =>
      boolean().withDefault(const Constant(false))(); // Vom User erstellt?
}

// 2. Definition von Routinen (z.B. "Push Day")
class Routines extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 50)();

  TextColumn get description => text().nullable()();
}

// 3. Verknüpfung: Welche Übungen gehören zu welcher Routine?
// Dies ist eine "Many-to-Many" Beziehungstabelle.
class RoutineExercises extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get routineId =>
      integer().references(Routines, #id, onDelete: KeyAction.cascade)();

  IntColumn get exerciseId =>
      integer().references(Exercises, #id, onDelete: KeyAction.cascade)();

  IntColumn get orderIndex =>
      integer()(); // Damit die Übungen in der richtigen Reihenfolge erscheinen
}

// 4. Ein durchgeführtes Workout (Die Session)
class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get date => dateTime()(); // Wann fand es statt?
  IntColumn get durationInSeconds =>
      integer().nullable()(); // Wie lange dauerte es?
  TextColumn get note => text().nullable()(); // "Fühlte mich heute schwach"

  // Optional: Wenn das Workout auf einer Routine basierte
  IntColumn get sourceRoutineId => integer().nullable().references(
    Routines,
    #id,
    onDelete: KeyAction.setNull,
  )();
}

// 5. Die eigentlichen Daten: Sätze
class WorkoutSets extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Zu welchem Workout gehört dieser Satz?
  IntColumn get workoutId =>
      integer().references(Workouts, #id, onDelete: KeyAction.cascade)();

  // Welche Übung war es?
  IntColumn get exerciseId => integer().references(Exercises, #id)();

  // Die Daten des Satzes
  RealColumn get weight => real()(); // Double, weil 22.5kg möglich sind
  IntColumn get reps => integer()();

  IntColumn get rpe =>
      integer().nullable()(); // Rate of Perceived Exertion (optional)

  // Ist es ein Warmup-Satz? (Wichtig für Statistiken - Warmup zählt oft nicht zum Volumen)
  BoolColumn get isWarmup => boolean().withDefault(const Constant(false))();

  // Wann wurde der Satz abgeschlossen? (Für den Rest-Timer)
  DateTimeColumn get completedAt => dateTime().nullable()();
}
