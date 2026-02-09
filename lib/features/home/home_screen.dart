import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_tracker/features/routines/data/routine_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Echte Daten laden
    final routinesAsync = ref.watch(routinesStreamProvider);

    return Scaffold(
      backgroundColor: Colors.black, // Background wie im Mockup
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Title + Streak)
              const _HeaderSection(),
              const SizedBox(height: 24),

              // 2. Weekly Goal Card
              const _WeeklyGoalCard(),
              const SizedBox(height: 24),

              // 3. Goals Section (Dummy)
              // TODO: Später durch echte Daten ersetzen
              const _SectionHeader(title: "Goals"),
              const SizedBox(height: 12),
              const _GoalTile(exercise: "Bench Press",
                  current: 81,
                  target: 100,
                  unit: "kg"),
              const SizedBox(height: 12),
              const _GoalTile(
                  exercise: "Squat", current: 120, target: 200, unit: "kg"),
              const SizedBox(height: 24),

              // 4. Routines (ECHTE DATEN)
              _SectionHeader(
                title: "Routines",
                onAdd: () => context.push('/create-routine'),
              ),
              const SizedBox(height: 12),

              routinesAsync.when(
                data: (routines) {
                  if (routines.isEmpty) {
                    return _EmptyRoutineState(
                        onTap: () => context.push('/create-routine'));
                  }
                  // Wir zeigen die Routinen an
                  return Column(
                    children: routines.map((routineData) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _RoutineCard(
                          title: routineData.routine.name,
                          subtitle: "${routineData.exercises.length} Exercises",
                          onTap: () {
                            context.push('/create-routine', extra: routineData);
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Text('Error: $err',
                        style: const TextStyle(color: Colors.red)),
              ),

              // Extra Platz unten, damit man nicht hinter der Navigation Bar scrollt
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGETS (Unverändert, aber Header angepasst) ---

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Dashboard", // Oder "Hello, [Name]"
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Streak Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: const Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orangeAccent,
                  size: 18), // Feuer Icon für Streak
              SizedBox(width: 4),
              Text("200", style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyGoalCard extends StatelessWidget {
  const _WeeklyGoalCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark Card Color
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Weekly Goal", style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          // Progress Bars (3 Segments)
          Row(
            children: [
              _buildSegment(isActive: false), // 1
              const SizedBox(width: 8),
              _buildSegment(isActive: false), // 2
              const SizedBox(width: 8),
              _buildSegment(isActive: false), // 3
            ],
          ),
          const SizedBox(height: 8),
          const Text("0/3 Workouts",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSegment({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.grey[700],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAdd;

  const _SectionHeader({required this.title, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
        if (onAdd != null)
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                  "+ New",
                  style: TextStyle(color: Colors.blueAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)
              ),
            ),
          )
      ],
    );
  }
}

class _GoalTile extends StatelessWidget {
  final String exercise;
  final double current;
  final double target;
  final String unit;

  const _GoalTile(
      {required this.exercise, required this.current, required this.target, required this.unit});

  @override
  Widget build(BuildContext context) {
    final percent = (current / target).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(exercise, style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
              Text("${(percent * 100).toInt()}%", style: const TextStyle(
                  color: Colors.greenAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text("${current.toInt()} $unit",
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: Colors.grey[800],
                    color: Colors.white, // Weißer Balken
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text("${target.toInt()} $unit",
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoutineCard(
      {required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[900]!),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.fitness_center, color: Colors.white70),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _EmptyRoutineState extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyRoutineState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Colors.grey[800]!, style: BorderStyle.solid),
        ),
        child: const Column(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.grey, size: 32),
            SizedBox(height: 8),
            Text("Create first Routine", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}