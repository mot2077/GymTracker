import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_tracker/core/database/app_database.dart';
import 'package:gym_tracker/features/exercises/data/exercise_repository.dart';
import 'package:gym_tracker/features/routines/data/routine_repository.dart';
import 'package:gym_tracker/features/routines/exercise_selection_screen.dart';

class RoutineEditScreen extends ConsumerStatefulWidget {
  // Wenn null, erstellen wir neu.
  final RoutineWithExercises? routineData;

  const RoutineEditScreen({super.key, this.routineData});

  @override
  ConsumerState<RoutineEditScreen> createState() => _RoutineEditScreenState();
}

class _RoutineEditScreenState extends ConsumerState<RoutineEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;

  // Die temporäre Liste der Übungen in dieser Routine
  List<Exercise> _selectedExercises = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.routineData?.routine.name ?? "",
    );
    _descController = TextEditingController(
      text: widget.routineData?.routine.description ?? "",
    );

    if (widget.routineData != null) {
      _selectedExercises = List.from(widget.routineData!.exercises);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Öffnet den Picker und aktualisiert die Liste
  Future<void> _pickExercises() async {
    // Wir brauchen die komplette Liste aller Übungen, um die IDs wieder in Objekte umzuwandeln
    final allExercises = await ref.read(exercisesStreamProvider.future);

    final currentIds = _selectedExercises.map((e) => e.id).toList();

    if (!mounted) return;

    // Navigiere zum Picker (wir nutzen push, da es ein modal sein könnte)
    final resultIds = await Navigator.push<List<int>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ExerciseSelectionScreen(initialSelectedIds: currentIds),
      ),
    );

    if (resultIds != null) {
      setState(() {
        // Wir behalten die Reihenfolge der BEREITS ausgewählten bei und fügen neue hinten an
        // Das ist etwas tricky:

        // 1. Welche sind neu?
        final newIds = resultIds.where((id) => !currentIds.contains(id));

        // 2. Welche wurden gelöscht?
        _selectedExercises.removeWhere((ex) => !resultIds.contains(ex.id));

        // 3. Neue hinzufügen
        for (var id in newIds) {
          final exerciseObj = allExercises.firstWhere((e) => e.id == id);
          _selectedExercises.add(exerciseObj);
        }
      });
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedExercises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please add at least one exercise.")),
        );
        return;
      }

      // Aktuell unterstützen wir nur CREATE, Update kommt später (ist komplexer wegen Reihenfolge)
      // Für diesen Schritt löschen wir einfach die alte und erstellen neu (dirty hack für prototyping)
      // oder wir bauen nur Create für jetzt.

      final repo = ref.read(routineRepositoryProvider);

      if (widget.routineData != null) {
        // TODO: Sauberes Update implementieren.
        // Für jetzt: Löschen und Neu erstellen (Achtung: History Verweise könnten verloren gehen,
        // aber wir haben noch keine History).
        await repo.deleteRoutine(widget.routineData!.routine.id);
      }

      await repo.createRoutine(
        name: _nameController.text,
        description: _descController.text,
        exercises: _selectedExercises,
      );

      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.routineData == null ? "New Routine" : "Edit Routine",
        ),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _save)],
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
                    decoration: const InputDecoration(
                      labelText: "Routine Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: "Description (Optional)",
                      border: OutlineInputBorder(),
                    ),
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
                  const Text(
                    "Exercises",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _pickExercises,
                    icon: const Icon(Icons.add),
                    label: const Text("Add / Remove"),
                  ),
                ],
              ),
            ),

            // Drag and Drop Liste
            Expanded(
              child: ReorderableListView.builder(
                itemCount: _selectedExercises.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = _selectedExercises.removeAt(oldIndex);
                    _selectedExercises.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final ex = _selectedExercises[index];
                  return ListTile(
                    key: ValueKey(ex.id),
                    // Wichtig für ReorderableListView
                    leading: const Icon(Icons.drag_handle),
                    title: Text(ex.name),
                    subtitle: Text(ex.targetMuscleGroup ?? ""),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _selectedExercises.removeAt(index);
                        });
                      },
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
