# 📌 Fitness-Tracker App Architektur & Komponenten
## 🔥 Hauptfunktionen der App
- **Workout-Tracking:** Erstellen, Speichern & Analysieren von Workouts
- **Statistiken & Fortschritt:** Gewicht, Muskelgruppen, Performance-Verbesserung
- **Recovery-Management:** Empfohlene Erholung basierend auf Muskelermüdung
- **Ranking-System:** Level-Aufstieg durch Aktivität
- **Weekly Goal:** Fortschrittsbalken für gesetzte Trainingsziele
- **Dark Mode & Anpassungen**

## Links
- Projektmanagement: https://www.notion.so/1c55c303dfd2807c87e9fc7593c0eb8a?v=1c55c303dfd281618ccc000c15d2ea25
- UI Mockup: https://www.canva.com/

## 📂 Ordnerstruktur
```
lib/
│── core/               # Zentrale Logik & Hilfsklassen
│   ├── constants/      # Globale Konstanten (Farben, Strings, Icons)
│   ├── utils/          # Helferklassen (z. B. Berechnungen für Recovery)
│   ├── theme/          # App-Design, Dark Mode
│   ├── services/       # Datenbank & API-Services (Hive-Implementierung)
│   ├── routing/        # App-Routing (GoRouter oder Navigator)
│
│── features/           # Feature-basierte Struktur (Clean Architecture)
│   ├── home/           # Home/Dashboard
│   │   ├── ui/         # UI (Widgets, Screens)
│   │   ├── application/  # Riverpod-Provider (State Management)
│   │   ├── data/         # Datenzugriff (Hive Models, Repositories)
│   │   ├── domain/       # Business-Logik (Use Cases, Models)
│   │   ├── home_page.dart
│   │
│   ├── workout/        # Workouts & Tracking
│   ├── stats/          # Statistiken & Graphen
│   ├── recovery/       # Recovery-Berechnungen & Tipps
│   ├── settings/       # Einstellungen
│
│── shared/             # Wiederverwendbare Komponenten
│   ├── widgets/        # Gemeinsame UI-Elemente (Buttons, Cards, Charts)
│   ├── providers/      # Globale Riverpod-Provider
│
│── main.dart           # Einstiegspunkt
│── app.dart            # App-Logik & Theme
│── dependencies.dart   # Dependency Injection (Riverpod)
```
---

## 📂 Teilbereiche der App (Untere Navigationsleiste)

### 🏋️ Routinen
- **Ziele-Balken**: Visualisiert, wie oft man bereits trainiert hat vs. das gesetzte Ziel  
- **Streak-Anzeige**: Anzahl an Workouts ohne mehr als X Tage Pause  
- **Workout-Routinen**: Vorlagen für z. B. Push/Pull/Legs  
- **Eigene Routinen erstellen**: Nutzer kann eigene Routinen definieren  
- **Kategorien**:  
  - Eigene Routinen  
  - Krafttraining  
  - Ausdauertraining  

### 📋 Übungen
- **Übersicht aller Übungen**: Liste mit Details zu jeder Übung  
- **Such- und Filterfunktion**: Finden von Übungen anhand von Muskelgruppen, Namen oder Tags  
- **Übungen hinzufügen & anpassen**: Eigene Übungen definieren  

### 📆 Workout-Historie
- **Trainingskalender**: Markiert Trainingstage grün  
- **Workout-Liste**: Alle durchgeführten Workouts chronologisch  
- **Vergleich zum letzten Mal**:  
  - Wieviel kg wurden insgesamt mehr/weniger bewegt?  
  - War die Trainingsdauer kürzer/länger?  
- **Filter-Funktion**:  
  - Suche nach Beintraining  
  - Suche basierend auf Routinen  

### 📊 Statistiken  

| **Persönliche Statistiken** | **Globale Statistiken** |
|----------------------------|-------------------------|
| Anzahl & Dauer von Workouts | Vergleich mit anderen: Welches Gewicht hebt man im Vergleich zur Welt? |
| Fortschritt in Übungen | Ranking: „Du drückst 100kg auf der Bank, damit gehörst du zu den Top 1%“ |
| Körpergewicht-Entwicklung |  |
| Anteil der Trainingsarten (Push/Pull/Legs in einem Pie Chart) |  |

---

## 🔥 Zusätzliche mögliche Features
### 📅 Planung & Automatisierung
- **Workout-Reminder**: Push-Benachrichtigungen für geplante Trainingstage  
- **Empfohlene Erholungszeit**: Automatische Berechnung, wann ein Muskel wieder trainiert werden kann  

### 🏆 Gamification & Motivation
- **Level-System**: Belohnungen für Meilensteine  
- **Badges & Erfolge**: Erhalte Abzeichen für z. B. 10 Tage in Folge trainieren  

### 🔗 Integration & Exporte
- **Datenexport**: Exportiere Trainingsdaten als CSV oder PDF  
- **Optionale API-Anbindung**: (falls später gewünscht) Verbindung mit Google Fit oder Apple Health  

🚀 **Nächste Schritte:** Soll ich eine UI-Skizze mit diesen Funktionen erstellen? 😊

---

## 🚀 Verwendete Komponenten & Technologien
### 📌 State Management
✅ **Riverpod** → Effiziente Zustandsverwaltung für Workouts & Statistiken

### 💾 Lokale Datenbank
✅ Drift (SQLite)

### 📊 Visualisierungen & UI
✅ fl_chart → Erstellung von Diagrammen für Statistiken & Fortschritt

✅ flutter_local_notifications → Erinnerungen an Workouts & Recovery

## 📜 Datenmodelle
```
class Workout {
  String id;
  String name;
  List<Exercise> exercises;
  DateTime date;
  int duration;
}

class Exercise {
  String name;
  int sets;
  List<int> reps;
  List<double> weights;
}

class Recovery {
  String muscleGroup;
  DateTime lastWorkout;
  int recommendedRecoveryTime;
}
```

## ✅ Nächste Schritte
1. UI-Prototyp in Flutter umsetzen (Start mit Home- & Workout-Screen)
2. Hive für lokale Speicherung einrichten
3. State Management mit Riverpod implementieren
4. Statistiken & Visualisierungen ergänzen
5. Recovery-Berechnungen & Ranks ausbauen

🚀 Damit hast du eine saubere Architektur für deine Fitness-Tracker-App!









