### 3. 🐙 GitHub Anbindung (Schritt für Schritt)

Wir machen das direkt aus Android Studio heraus, das ist am einfachsten.

**Vorraussetzung:** Du hast einen GitHub Account.

1.  **Repository auf GitHub erstellen:**
    * Gehe auf [github.com/new](https://github.com/new).
    * Name: `gym-tracker` (oder wie du willst).
    * Description: "Flutter Fitness App".
    * **WICHTIG:** Wähle "Public" oder "Private".
    * Lass "Add a README file", ".gitignore" und "License" **leer** (Das haben wir lokal schon durch Flutter).
    * Klicke **Create repository**.
    * Kopiere die URL (HTTPS), die dir angezeigt wird (z.B. `https://github.com/DeinName/gym-tracker.git`).

2.  **Git im Projekt initialisieren:**
    * In Android Studio: Oben im Menü auf **VCS** (oder **Git**, je nach Version) -> **Enable Version Control Integration**.
    * Wähle **Git** aus dem Dropdown und klicke **OK**.
    * Alle Dateinamen im Projekt-Explorer werden nun rot (bedeutet: noch nicht getrackt).

3.  **Dateien hinzufügen & erster Commit:**
    * Öffne den Reiter **Commit** (meistens links am Rand) oder drücke `Strg + K` (Mac: `Cmd + K`).
    * Hake alle Dateien an ("Unversioned Files").
    * Commit Message: `Initial commit: Project setup`.
    * Klicke auf **Commit**.

4.  **Mit GitHub verbinden (Remote hinzufügen):**
    * Gehe im Menü auf **Git** -> **Manage Remotes...**.
    * Klicke auf das **+**.
    * Name: `origin`.
    * URL: Füge hier die URL ein, die du eben bei GitHub kopiert hast.
    * Klicke **OK**.

5.  **Hochladen (Push):**
    * Gehe im Menü auf **Git** -> **Push...** (oder `Strg + Shift + K`).
    * Klicke **Push**.
    * Fertig! Dein Code ist jetzt auf GitHub.

---

### 4. 📂 Die Struktur anlegen (Clean Setup)

Mache jetzt folgendes in Android Studio im Projekt-Explorer (unter `lib/`):

1.  Lösche den ganzen Inhalt von `main.dart` (wir schreiben den später neu).
2.  Rechtsklick auf `lib` -> **New** -> **Directory**.
3.  Erstelle folgende Ordner nacheinander:
    * `core`
    * `core/theme`
    * `core/database`
    * `features`
    * `shared`
    * `shared/widgets`

4.  Erstelle jetzt eine neue Datei `README.md` im Hauptverzeichnis des Projekts (auf der gleichen Ebene wie `pubspec.yaml`, *nicht* in `lib`) und füge den Text von oben ein.