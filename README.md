# 🏋️ GymTracker

Ein Offline-First Fitness-Tracker, entwickelt mit Flutter, um professionelle Analytics-Funktionen ohne Paywalls zu bieten.

## 🎯 Projektziel
Entwicklung einer performanten, lokalen Fitness-App, die es ermöglicht, Workouts zu tracken, eigene Routinen zu erstellen und detaillierte Fortschrittsanalysen (Volumen, 1RM, Split-Verteilung) einzusehen.

## 🏗️ Tech Stack & Architektur

Dieses Projekt folgt der **Clean Architecture** und nutzt einen **Feature-First** Ansatz.

| Bereich | Technologie | Begründung |
| :--- | :--- | :--- |
| **Framework** | Flutter & Dart | Cross-Platform, High-Performance Rendering |
| **State Management** | **Riverpod** | Compile-safe, testbar, entkoppelt UI von Logik |
| **Datenbank** | **Drift (SQLite)** | Relational (SQL), Typ-sicher, performant für komplexe Statistiken |
| **Navigation** | **GoRouter** | Deep-Linking Support, deklaratives Routing |
| **Charts** | fl_chart | Hochwertige Visualisierungen für Statistiken |
| **Code Gen** | Freezed & Build Runner | Reduziert Boilerplate-Code (Data Classes, Unions) |

## 📂 Ordnerstruktur (Feature-First)

```text
lib/
│── core/               # Globale Konfigurationen & Utils
│   ├── theme/          # Farben, Styles, Dark Mode Logik
│   ├── database/       # Drift Datenbank Konfiguration
│   └── utils/          # Helper (z.B. Datums-Formatierung)
│
│── features/           # Jedes Feature ist ein eigenes Modul
│   ├── workout/        # Tracking Logik, Active Session
│   ├── routines/       # Plan-Management (Push/Pull/Legs etc.)
│   ├── history/        # Kalender & Vergangene Workouts
│   └── statistics/     # Graphen & Analysen
│       ├── data/       # Repositories & DTOs
│       ├── domain/     # Models & Business Logic
│       └── presentation/ # Widgets & Riverpod Controller
│
│── shared/             # Wiederverwendbare UI-Komponenten
│   ├── widgets/        # Buttons, Inputs, Cards
│   └── models/         # Gemeinsam genutzte Datenmodelle
│
└── main.dart           # Einstiegspunkt
