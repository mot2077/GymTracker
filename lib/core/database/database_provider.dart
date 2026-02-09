import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/core/database/app_database.dart';

// Dieser Provider stellt sicher, dass wir immer dieselbe Instanz der Datenbank nutzen (Singleton)
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();

  // Wenn die App geschlossen wird (oder der Provider nicht mehr gebraucht wird),
  // schließen wir die Verbindung sauber.
  ref.onDispose(() {
    database.close();
  });

  return database;
});
