import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_tracker/features/routines/data/routine_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wir lauschen auf den Stream der Routinen (Live-Updates!)
    final routinesAsync = ref.watch(routinesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals & Routines'),
        centerTitle: false, // Linksbuendig wirkt oft moderner
      ),

      // Der "Add Routine" Button (wie im Mockup "New Routine", hier als FAB für den Anfang)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigiere zum Erstell-Screen
          context.push('/create-routine');
        },
        icon: const Icon(Icons.add),
        label: const Text("New Routine"),
      ),

      body: routinesAsync.when(
        data: (routines) {
          if (routines.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                      Icons.fitness_center, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "No routines yet.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.push('/create-routine'),
                    child: const Text("Create your first routine"),
                  ),
                ],
              ),
            );
          }

          // Liste der Routinen
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routineData = routines[index];
              final routine = routineData.routine;
              final exercises = routineData.exercises;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  title: Text(
                    routine.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (routine.description != null &&
                          routine.description!.isNotEmpty)
                        Text(routine.description!, style: TextStyle(
                            color: Colors.grey[400])),
                      const SizedBox(height: 4),
                      // Zeige an, wie viele Übungen drin sind
                      Text(
                        "${exercises.length} Exercises",
                        style: TextStyle(
                            color: Theme
                                .of(context)
                                .primaryColor,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      // Optional: Kleine Vorschau der Übungsnamen
                      if (exercises.isNotEmpty)
                        Text(
                          exercises.take(3).map((e) => e.name).join(", ") +
                              (exercises.length > 3 ? "..." : ""),
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Später hier Detail-Ansicht oder Workout-Start öffnen
                    // Aktuell öffnen wir den Editor zum Bearbeiten
                    // Da wir Update noch nicht implementiert haben, ist das nur zum Testen
                  },
                  // Optional: Slide to delete könnte man hier einbauen
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}