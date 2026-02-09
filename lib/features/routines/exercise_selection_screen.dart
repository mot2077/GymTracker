import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_tracker/features/exercises/data/exercise_repository.dart';

class ExerciseSelectionScreen extends ConsumerStatefulWidget {
  // Welche Übungen sind schon ausgewählt?
  final List<int> initialSelectedIds;

  const ExerciseSelectionScreen({
    super.key,
    this.initialSelectedIds = const [],
  });

  @override
  ConsumerState<ExerciseSelectionScreen> createState() =>
      _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState
    extends ConsumerState<ExerciseSelectionScreen> {
  final Set<int> _selectedIds = {};
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(widget.initialSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Exercises"),
        actions: [
          TextButton(
            onPressed: () {
              // Wir geben die Liste der ausgewählten IDs zurück (oder ganze Objekte)
              // Hier geben wir erst mal nur IDs zurück, um es einfach zu halten,
              // oder besser: Wir geben die Objekte zurück, damit wir sie anzeigen können.
              // Da wir hier nur IDs haben, holen wir uns die Objekte aus dem Stream.
              // (Vereinfachung: Wir geben das Ergebnis zurück)
              context.pop(_selectedIds.toList());
            },
            child: const Text(
              "Done",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                final filtered = exercises
                    .where(
                      (e) => e.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final ex = filtered[index];
                    final isSelected = _selectedIds.contains(ex.id);

                    return CheckboxListTile(
                      title: Text(ex.name),
                      subtitle: Text(ex.targetMuscleGroup ?? ""),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedIds.add(ex.id);
                          } else {
                            _selectedIds.remove(ex.id);
                          }
                        });
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text("Error: $e")),
            ),
          ),
        ],
      ),
    );
  }
}
