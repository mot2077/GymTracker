import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_tracker/features/exercises/data/exercise_repository.dart';
import 'package:gym_tracker/features/routines/data/routine_repository.dart';
import 'package:gym_tracker/features/routines/exercise_selection_screen.dart';

class RoutineEditScreen extends ConsumerStatefulWidget {
  final RoutineWithExercises? routineData; // Null = Neu, Objekt = Bearbeiten

  const RoutineEditScreen({super.key, this.routineData});

  @override
  ConsumerState<RoutineEditScreen> createState() => _RoutineEditScreenState();
}

class _RoutineEditScreenState extends ConsumerState<RoutineEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;

  // Unsere Liste enthält jetzt Übung + Sätze
  List<RoutineExerciseData> _selectedExercises = [];

  bool get _isEditing => widget.routineData != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.routineData?.routine.name ?? "");
    _descController = TextEditingController(
        text: widget.routineData?.routine.description ?? "");

    if (_isEditing) {
      // Kopie der Liste erstellen, damit wir bearbeiten können
      _selectedExercises = List.from(widget.routineData!.exercises);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickExercises() async {
    final allExercises = await ref.read(exercisesStreamProvider.future);
    final currentIds = _selectedExercises.map((e) => e.exercise.id).toList();

    if (!mounted) return;

    final resultIds = await Navigator.push<List<int>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ExerciseSelectionScreen(initialSelectedIds: currentIds),
      ),
    );

    if (resultIds != null) {
      setState(() {
        // 1. Gelöschte entfernen
        _selectedExercises.removeWhere((ex) =>
        !resultIds.contains(ex.exercise.id));

        // 2. Neue hinzufügen (mit Standard 1 Satz)
        // Wir filtern IDs, die noch NICHT in der aktuellen Liste sind
        final newIds = resultIds.where((id) => !currentIds.contains(id));

        for (var id in newIds) {
          final exerciseObj = allExercises.firstWhere((e) => e.id == id);
          _selectedExercises.add(RoutineExerciseData(
              exercise: exerciseObj, sets: 1)); // Default: 1 Set
        }
      });
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedExercises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Add at least one exercise")));
        return;
      }

      final repo = ref.read(routineRepositoryProvider);

      if (_isEditing) {
        // UPDATE (ID behalten!)
        await repo.updateRoutine(
          routineId: widget.routineData!.routine.id,
          name: _nameController.text,
          description: _descController.text,
          exercises: _selectedExercises,
        );
      } else {
        // CREATE
        await repo.createRoutine(
          name: _nameController.text,
          description: _descController.text,
          exercises: _selectedExercises,
        );
      }

      if (mounted) context.pop();
    }
  }

  // Löschen Funktion
  Future<void> _deleteRoutine() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text("Delete Routine?"),
            content: const Text("Currently active workouts might be affected."),
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
      await ref.read(routineRepositoryProvider).deleteRoutine(
          widget.routineData!.routine.id);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Routine" : "New Routine"),
        actions: [
          if (_isEditing)
            IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: _deleteRoutine),
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Routine Name",
                        border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(
                        labelText: "Description (Optional)",
                        border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Exercises & Sets", style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: _pickExercises,
                    icon: const Icon(Icons.add),
                    label: const Text("Manage"),
                  )
                ],
              ),
            ),

            // Drag & Drop Liste mit Set-Counter
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: _selectedExercises.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) newIndex -= 1;
                    final item = _selectedExercises.removeAt(oldIndex);
                    _selectedExercises.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final data = _selectedExercises[index];

                  return Card(
                    key: ValueKey(data.exercise.id), // Wichtig für Reorder
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: ListTile(
                      contentPadding: const EdgeInsets.only(
                          left: 16, right: 8, top: 4, bottom: 4),
                      leading: const Icon(
                          Icons.drag_handle, color: Colors.grey),
                      title: Text(data.exercise.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(data.exercise.targetMuscleGroup ?? "-"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // SETS COUNTER
                          const Text("Sets: ", style: TextStyle(
                              fontSize: 12, color: Colors.grey)),
                          IconButton(
                            icon: const Icon(
                                Icons.remove_circle_outline, size: 20),
                            onPressed: () {
                              if (data.sets > 1) {
                                setState(() {
                                  // Update Set Count
                                  _selectedExercises[index] =
                                      data.copyWith(sets: data.sets - 1);
                                });
                              }
                            },
                          ),
                          Text(
                              "${data.sets}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)
                          ),
                          IconButton(
                            icon: const Icon(
                                Icons.add_circle_outline, size: 20),
                            onPressed: () {
                              if (data.sets < 10) { // Limit 10 Sets
                                setState(() {
                                  _selectedExercises[index] =
                                      data.copyWith(sets: data.sets + 1);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}