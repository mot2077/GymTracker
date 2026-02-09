import 'package:drift/drift.dart' show Value; // WICHTIG: Value importieren!
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_tracker/core/database/app_database.dart';
import 'package:gym_tracker/core/database/models/exercise_type.dart';
import 'package:gym_tracker/features/exercises/data/exercise_repository.dart';

class ExerciseEditScreen extends ConsumerStatefulWidget {
  final Exercise exercise;

  const ExerciseEditScreen({super.key, required this.exercise});

  @override
  ConsumerState<ExerciseEditScreen> createState() => _ExerciseEditScreenState();
}

class _ExerciseEditScreenState extends ConsumerState<ExerciseEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller für Textfelder
  late TextEditingController _nameController;
  late TextEditingController _equipmentController;

  // State für Dropdowns
  late String _selectedMuscle;
  late ExerciseLogType _selectedLogType;

  // Unsere Listen für die Dropdowns
  final List<String> _muscleGroups = [
    "Chest",
    "Back",
    "Legs",
    "Abs",
    "Arms",
    "Shoulders",
    "Cardio",
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise.name);
    _equipmentController = TextEditingController(
      text: widget.exercise.primaryEquipment,
    );

    // Fallback, falls die aktuelle Muskelgruppe nicht in unserer Liste ist
    _selectedMuscle = _muscleGroups.contains(widget.exercise.targetMuscleGroup)
        ? widget.exercise.targetMuscleGroup!
        : "Chest";

    // KORREKTUR 1: Drift liefert das Enum direkt, kein Integer-Index nötig
    _selectedLogType = widget.exercise.logType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      // 1. Objekt kopieren mit neuen Werten
      final updatedExercise = widget.exercise.copyWith(
        name: _nameController.text,

        // KORREKTUR 2: Nullable Felder müssen in Value() gewrappt werden
        targetMuscleGroup: Value(_selectedMuscle),
        primaryEquipment: Value(_equipmentController.text),

        // KORREKTUR 3: Enum direkt übergeben, nicht den Index
        logType: _selectedLogType,
      );

      // 2. An Repository senden
      await ref
          .read(exerciseRepositoryProvider)
          .updateExercise(updatedExercise);

      // 3. Zurück navigieren
      if (mounted) context.pop();
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Exercise?"),
        content: const Text(
          "This cannot be undone. It will also be removed from history.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(exerciseRepositoryProvider)
          .deleteExercise(widget.exercise.id);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Exercise"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: _delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Name ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Exercise Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Name is required" : null,
              ),
              const SizedBox(height: 16),

              // --- Muscle Group Dropdown ---
              DropdownButtonFormField<String>(
                initialValue: _selectedMuscle,
                decoration: const InputDecoration(
                  labelText: "Target Muscle",
                  border: OutlineInputBorder(),
                ),
                items: _muscleGroups
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedMuscle = val!),
              ),
              const SizedBox(height: 16),

              // --- Log Type Dropdown (Optimiert) ---
              DropdownButtonFormField<ExerciseLogType>(
                value: _selectedLogType,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "Tracking Type",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),

                // 1. Die Liste, die aufgeklappt wird (Titel + Beispiele)
                items: ExerciseLogType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getReadableLogType(type),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2), // Kleiner Abstand
                        Text(
                          _getExampleText(type),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }).toList(),

                // 2. WICHTIG: Die Ansicht, wenn das Menü geschlossen ist (Nur Titel)
                selectedItemBuilder: (BuildContext context) {
                  return ExerciseLogType.values.map((type) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _getReadableLogType(type),
                        // Hier nur den Titel anzeigen!
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList();
                },

                // 3. Layout-Optimierungen
                itemHeight: 65,
                // Genug Platz für 2 Zeilen im Menü
                menuMaxHeight: 400,
                // Begrenzt die Höhe, erzwingt oft das Öffnen nach unten/mittig
                onChanged: (val) => setState(() => _selectedLogType = val!),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 16),

              // --- Equipment ---
              TextFormField(
                controller: _equipmentController,
                decoration: const InputDecoration(
                  labelText: "Equipment",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),

              // --- Save Button ---
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Titel: Beschreibt die Kategorie
  String _getReadableLogType(ExerciseLogType type) {
    switch (type) {
      case ExerciseLogType.weightReps:
        // Deckt ab: Kraft, Weighted BW, Assisted BW
        return "Weight & Reps (Standard Strength)";
      case ExerciseLogType.repOnly:
        // Deckt ab: Bodyweight
        return "Reps Only (Bodyweight)";
      case ExerciseLogType.timeDistance:
        // Deckt ab: Cardio
        return "Cardio (Time & Distance)";
      case ExerciseLogType.timeWeight:
        // Deckt ab: Isometrisch
        return "Duration & Weight (Isometric)";
    }
  }

  // Beispiele: Erklären dem User, was er wählen soll
  String _getExampleText(ExerciseLogType type) {
    switch (type) {
      case ExerciseLogType.weightReps:
        return "Ex: Bench Press, Weighted Pull-ups, Assisted Dips (-kg)";
      case ExerciseLogType.repOnly:
        return "Ex: Push-ups, Air Squats, Crunches";
      case ExerciseLogType.timeDistance:
        return "Ex: Running, Cycling, Rowing";
      case ExerciseLogType.timeWeight:
        return "Ex: Plank, Wall Sit, Static Holds";
    }
  }
}
