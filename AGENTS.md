# AGENTS.md

## Cursor Cloud specific instructions

This is a **Flutter (Dart) Point-of-Sale UI** app — a single, client-only product with no backend, database, or external services. All data is hardcoded in `lib/`.

### Toolchain
- Flutter **3.7.12** (Dart **2.19.6**) is installed at `~/flutter`. A newer Flutter (3.10+) ships Dart 3, which violates this project's `pubspec.yaml` SDK constraint `>=2.17.6 <3.0.0`, so do **not** upgrade past the 3.7.x line.
- `~/flutter/bin` is added to `PATH` via `~/.bashrc`. If `flutter` is not found in a fresh non-login shell, run `export PATH="$HOME/flutter/bin:$PATH"`.

### Common commands (run from repo root)
- Install deps: `flutter pub get`
- Lint: `flutter analyze` (only info-level lints exist; no errors)
- Test: `flutter test`
- Run (web dev): `flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0`, then open `http://localhost:8080`. Chrome (`google-chrome`) is available; `flutter run -d chrome` also works.

### Non-obvious caveats
- `test/widget_test.dart` is the leftover **default Flutter counter template test** ("Counter increments smoke test"). It does **not** match this POS app and therefore **fails** — this is a pre-existing repo issue, not an environment problem. Do not treat this failure as a setup regression.
- The app is a static UI demo: most controls (search bar, category tabs, "Print Bills") are no-ops. The only real interaction is the **left sidebar navigation** (`_setPage` in `lib/main.dart`), which switches the active page and animates the orange highlight. Only the "Home" page has content; Menu/History/Promos/Settings are empty placeholders.
- The web app shows a blank dark screen for ~10-15s on first load while it compiles/initializes — wait before concluding it failed.
