import 'package:drift/drift.dart';

import 'models/exercise_type.dart';

// 1. Exercises
class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();

  TextColumn get targetMuscleGroup =>
      text().nullable()(); // "Chest", "Back", etc.
  TextColumn get primaryEquipment => text().nullable()();

  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();

  // Stores which fields are needed (0=WeightReps, 1=RepOnly, etc.)
  IntColumn get logType => intEnum<ExerciseLogType>()();
}

// 2. Routines
class Routines extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get description => text().nullable()();
}

// 3. RoutineExercises (Many-to-Many)
class RoutineExercises extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get routineId =>
      integer().references(Routines, #id, onDelete: KeyAction.cascade)();

  IntColumn get exerciseId =>
      integer().references(Exercises, #id, onDelete: KeyAction.cascade)();

  IntColumn get orderIndex => integer()();

  IntColumn get sets => integer().withDefault(const Constant(1))();
}

// 4. Workouts (The Session)
class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get date => dateTime()();

  IntColumn get durationInSeconds => integer().nullable()();

  TextColumn get note => text().nullable()(); // General workout note
  IntColumn get sourceRoutineId =>
      integer().nullable().references(
          Routines, #id, onDelete: KeyAction.setNull)();
}

// 5. WorkoutSets ( The Data)
class WorkoutSets extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get workoutId =>
      integer().references(Workouts, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();

  // Flexible Data Fields (nullable depending on logType)
  RealColumn get weight => real().nullable()();

  IntColumn get reps => integer().nullable()();

  IntColumn get durationInSeconds => integer().nullable()();

  RealColumn get distanceInKm => real().nullable()();

  IntColumn get calories => integer().nullable()();

  // Meta Data
  IntColumn get rpe => integer().nullable()();
  BoolColumn get isWarmup => boolean().withDefault(const Constant(false))();

  TextColumn get note => text().nullable()(); // NEU: Note per Set
  DateTimeColumn get completedAt => dateTime().nullable()();
}