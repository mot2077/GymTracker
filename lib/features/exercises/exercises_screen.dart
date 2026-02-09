import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/features/exercises/data/exercise_repository.dart';

// State für den ausgewählten Filter (null = Alle)
final selectedMuscleFilterProvider = StateProvider<String?>((ref) => null);
// State für Suchtext
final exerciseSearchProvider = StateProvider<String>((ref) => '');

class ExercisesScreen extends ConsumerWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(exercisesStreamProvider);
    final searchQuery = ref.watch(exerciseSearchProvider);
    final selectedFilter = ref.watch(selectedMuscleFilterProvider);

    // Unsere festen Filter-Kategorien
    final List<String> filterCategories = [
      "Chest",
      "Back",
      "Legs",
      "Arms",
      "Abs",
      "Cardio"
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search exercise...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                filled: true,
                fillColor: Theme
                    .of(context)
                    .cardColor,
              ),
              onChanged: (val) =>
              ref
                  .read(exerciseSearchProvider.notifier)
                  .state = val,
            ),
          ),

          // 2. Filter Chips (Horizontal Scrollable)
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // "All" Chip
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: const Text("All"),
                    selected: selectedFilter == null,
                    onSelected: (bool selected) {
                      ref
                          .read(selectedMuscleFilterProvider.notifier)
                          .state = null;
                    },
                  ),
                ),
                // Dynamic Chips
                ...filterCategories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(category),
                      selected: selectedFilter == category,
                      onSelected: (bool selected) {
                        ref
                            .read(selectedMuscleFilterProvider.notifier)
                            .state =
                        selected ? category : null;
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const Divider(),

          // 3. The List
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                // Logik: Erst Filtern, dann Suchen
                final filtered = exercises.where((ex) {
                  // Filter Check
                  if (selectedFilter != null &&
                      ex.targetMuscleGroup != selectedFilter) {
                    return false;
                  }
                  // Search Check
                  if (searchQuery.isNotEmpty && !ex.name.toLowerCase().contains(
                      searchQuery.toLowerCase())) {
                    return false;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text("No exercises found",
                        style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final ex = filtered[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme
                            .of(context)
                            .colorScheme
                            .primaryContainer,
                        child: Text(ex.name.substring(0, 1).toUpperCase()),
                      ),
                      title: Text(ex.name),
                      subtitle: Text(ex.primaryEquipment ?? ""),
                      trailing: const Icon(Icons.add_circle_outline),
                      onTap: () {
                        // TODO: Open Details or Add to Routine
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}