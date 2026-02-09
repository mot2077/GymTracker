import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_tracker/core/database/app_database.dart';
import 'package:gym_tracker/core/database/models/exercise_type.dart';
import 'package:gym_tracker/features/exercises/data/exercise_repository.dart';

class ExerciseEditScreen extends ConsumerStatefulWidget {
  // Das Exercise ist jetzt optional (nullable)
  final Exercise? exercise;

  const ExerciseEditScreen({super.key, this.exercise});

  @override
  ConsumerState<ExerciseEditScreen> createState() => _ExerciseEditScreenState();
}

class _ExerciseEditScreenState extends ConsumerState<ExerciseEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _equipmentController;
  late String _selectedMuscle;
  late ExerciseLogType _selectedLogType;

  final List<String> _muscleGroups = [
    "Chest",
    "Back",
    "Legs",
    "Arms",
    "Abs",
    "Cardio",
    "Shoulders"
  ];

  // Helper: Sind wir im Bearbeitungs-Modus?
  bool get _isEditing => widget.exercise != null;

  @override
  void initState() {
    super.initState();
    // Wenn Bearbeiten: Werte laden. Wenn Neu: Standardwerte setzen.
    _nameController = TextEditingController(text: widget.exercise?.name ?? "");
    _equipmentController =
        TextEditingController(text: widget.exercise?.primaryEquipment ?? "");

    _selectedMuscle = widget.exercise?.targetMuscleGroup != null &&
        _muscleGroups.contains(widget.exercise!.targetMuscleGroup)
        ? widget.exercise!.targetMuscleGroup!
        : "Chest"; // Standard

    _selectedLogType =
        widget.exercise?.logType ?? ExerciseLogType.weightReps; // Standard
  }

  @override
  void dispose() {
    _nameController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final repo = ref.read(exerciseRepositoryProvider);

      if (_isEditing) {
        // UPDATE LOGIK
        final updatedExercise = widget.exercise!.copyWith(
          name: _nameController.text,
          targetMuscleGroup: Value(_selectedMuscle),
          primaryEquipment: Value(_equipmentController.text),
          logType: _selectedLogType,
        );
        await repo.updateExercise(updatedExercise);
      } else {
        // CREATE LOGIK
        await repo.addExercise(
          name: _nameController.text,
          targetMuscle: _selectedMuscle,
          equipment: _equipmentController.text,
          logType: _selectedLogType,
        );
      }

      if (mounted) context.pop();
    }
  }

  Future<void> _delete() async {
    if (!_isEditing) return; // Sollte nicht passieren, da Button ausgeblendet

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Exercise?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(exerciseRepositoryProvider).deleteExercise(
          widget.exercise!.id);
      if (mounted) context.pop();
    }
  }

  // --- UI Helper Functions (Titel & Beispiele) ---
  String _getReadableLogType(ExerciseLogType type) {
    switch (type) {
      case ExerciseLogType.weightReps:
        return "Weight & Reps (Strength)";
      case ExerciseLogType.repOnly:
        return "Reps Only (Bodyweight)";
      case ExerciseLogType.timeDistance:
        return "Time & Distance (Cardio)";
      case ExerciseLogType.timeWeight:
        return "Time & Weight (Isometric)";
    }
  }

  String _getExampleText(ExerciseLogType type) {
    switch (type) {
      case ExerciseLogType.weightReps:
        return "Ex: Bench Press, Weighted Pull-ups";
      case ExerciseLogType.repOnly:
        return "Ex: Push-ups, Air Squats";
      case ExerciseLogType.timeDistance:
        return "Ex: Running, Cycling";
      case ExerciseLogType.timeWeight:
        return "Ex: Plank, Static Holds";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Dynamischer Titel
        title: Text(_isEditing ? "Edit Exercise" : "New Exercise"),
        actions: [
          // Löschen-Button nur anzeigen, wenn wir bearbeiten
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: _delete,
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: "Name", border: OutlineInputBorder()),
                validator: (val) =>
                val == null || val.isEmpty
                    ? "Required"
                    : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedMuscle,
                decoration: const InputDecoration(
                    labelText: "Target Muscle", border: OutlineInputBorder()),
                items: _muscleGroups.map((m) =>
                    DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (val) => setState(() => _selectedMuscle = val!),
              ),
              const SizedBox(height: 16),

              // Unser optimiertes Dropdown von vorhin
              DropdownButtonFormField<ExerciseLogType>(
                initialValue: _selectedLogType,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "Tracking Type",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
                items: ExerciseLogType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_getReadableLogType(type), style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(_getExampleText(type), style: TextStyle(
                            fontSize: 11, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  );
                }).toList(),
                selectedItemBuilder: (BuildContext context) {
                  return ExerciseLogType.values.map((type) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_getReadableLogType(type),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis),
                    );
                  }).toList();
                },
                itemHeight: 65,
                menuMaxHeight: 400,
                onChanged: (val) => setState(() => _selectedLogType = val!),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _equipmentController,
                decoration: const InputDecoration(
                    labelText: "Equipment", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _save,
                icon: Icon(_isEditing ? Icons.save : Icons.add),
                label: Text(_isEditing ? "Save Changes" : "Create Exercise"),
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
}