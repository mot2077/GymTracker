import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_tracker/features/exercises/data/exercise_repository.dart';

import '../../core/database/models/exercise_type.dart';

// State für den ausgewählten Filter (null = Alle)
final selectedMuscleFilterProvider = StateProvider<String?>((ref) => null);
// State für Suchtext
final exerciseSearchProvider = StateProvider<String>((ref) => '');

class ExercisesScreen extends ConsumerWidget {
  const ExercisesScreen({super.key});

  // Hilfsfunktion für das Icon basierend auf dem Tracking-Typ
  Widget _buildLeadingIcon(ExerciseLogType type, BuildContext context) {
    IconData icon;
    Color color;

    switch (type) {
      case ExerciseLogType.weightReps:
        icon = Icons.fitness_center; // Hantel
        color = Colors.blueAccent;
        break;
      case ExerciseLogType.repOnly:
        icon = Icons.accessibility_new; // Person / Körpergewicht
        color = Colors.green;
        break;
      case ExerciseLogType.timeDistance:
        icon = Icons.directions_run; // Laufen
        color = Colors.orange;
        break;
      case ExerciseLogType.timeWeight:
        icon = Icons.timer; // Uhr
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15), // Leichter Hintergrund
        borderRadius: BorderRadius.circular(
            8), // Eckig statt rund wirkt technischer
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

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

                    // Logik für den Untertitel: Verbinde Muskel & Equipment
                    final List<String> subtitleParts = [
                      ex.targetMuscleGroup ?? "",
                      ex.primaryEquipment ?? ""
                    ]
                        .where((s) => s.isNotEmpty)
                        .toList(); // Leere Strings filtern

                    final subtitleText = subtitleParts.join(", ");

                    return ListTile(
                      // Neues Icon System statt Buchstaben
                      leading: _buildLeadingIcon(ex.logType, context),

                      title: Text(
                        ex.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),

                      // Neuer Untertitel (z.B. "Chest • Barbell")
                      subtitle: Text(
                        subtitleText,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),

                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () =>
                            context.push('/edit-exercise', extra: ex),
                      ),
                      onTap: () => context.push('/edit-exercise', extra: ex),
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