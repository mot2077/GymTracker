import 'package:drift/drift.dart';
import 'package:gym_tracker/core/database/app_database.dart';
import 'package:gym_tracker/core/database/models/exercise_type.dart';

List<ExercisesCompanion> getInitialExercises() {
  return [
    // --- CHEST ---
    ExercisesCompanion.insert(
      name: 'Bench Press (Barbell)',
      targetMuscleGroup: const Value('Chest'),
      primaryEquipment: const Value('Barbell'),
      logType: ExerciseLogType.weightReps,
    ),
    ExercisesCompanion.insert(
      name: 'Push Ups',
      targetMuscleGroup: const Value('Chest'),
      primaryEquipment: const Value('Bodyweight'),
      logType: ExerciseLogType.repOnly,
    ),

    // --- BACK ---
    ExercisesCompanion.insert(
      name: 'Deadlift',
      targetMuscleGroup: const Value('Back'),
      primaryEquipment: const Value('Barbell'),
      logType: ExerciseLogType.weightReps,
    ),
    ExercisesCompanion.insert(
      name: 'Pull Ups',
      targetMuscleGroup: const Value('Back'),
      primaryEquipment: const Value('Bodyweight'),
      logType: ExerciseLogType.repOnly, // Can be WeightReps if weighted
    ),

    // --- LEGS ---
    ExercisesCompanion.insert(
      name: 'Squat (Barbell)',
      targetMuscleGroup: const Value('Legs'),
      primaryEquipment: const Value('Barbell'),
      logType: ExerciseLogType.weightReps,
    ),
    ExercisesCompanion.insert(
      name: 'Leg Press',
      targetMuscleGroup: const Value('Legs'),
      primaryEquipment: const Value('Machine'),
      logType: ExerciseLogType.weightReps,
    ),

    // --- ARMS ---
    ExercisesCompanion.insert(
      name: 'Bicep Curl (Dumbbell)',
      targetMuscleGroup: const Value('Arms'),
      primaryEquipment: const Value('Dumbbell'),
      logType: ExerciseLogType.weightReps,
    ),
    ExercisesCompanion.insert(
      name: 'Tricep Dips',
      targetMuscleGroup: const Value('Arms'),
      primaryEquipment: const Value('Bodyweight'),
      logType: ExerciseLogType.repOnly,
    ),

    // --- ABS ---
    ExercisesCompanion.insert(
      name: 'Plank',
      targetMuscleGroup: const Value('Abs'),
      primaryEquipment: const Value('Bodyweight'),
      logType: ExerciseLogType.timeWeight,
    ),
    ExercisesCompanion.insert(
      name: 'Crunches',
      targetMuscleGroup: const Value('Abs'),
      primaryEquipment: const Value('Bodyweight'),
      logType: ExerciseLogType.repOnly,
    ),

    // --- CARDIO ---
    ExercisesCompanion.insert(
      name: 'Running (Treadmill)',
      targetMuscleGroup: const Value('Cardio'),
      primaryEquipment: const Value('Machine'),
      logType: ExerciseLogType.timeDistance,
    ),
    ExercisesCompanion.insert(
      name: 'Cycling',
      targetMuscleGroup: const Value('Cardio'),
      primaryEquipment: const Value('Machine'),
      logType: ExerciseLogType.timeDistance,
    ),
  ];
}
