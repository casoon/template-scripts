# create-astro-project.sh

Dieses Skript erstellt ein neues [Astro.js](https://astro.build/)-Projekt mit Alpine.js-Integration, @casoon-Komponenten und MDX-Unterstützung.

## Funktionen

Das Skript automatisiert folgende Schritte:

1. Erstellt ein neues Astro-Projekt basierend auf dem minimalen Template
2. Installiert alle notwendigen Abhängigkeiten:
   - @casoon/ui-lib
   - @casoon/astro-components  
   - alpinejs
   - @astrojs/alpinejs
   - @astrojs/mdx
3. Konfiguriert die Astro-Integrationen (MDX, Alpine.js)
4. Richtet Alpine.js mit benutzerdefinierten Direktiven und Stores ein
5. Erstellt ein Basis-Layout mit Dark/Light-Mode Toggle
6. Fügt eine Beispiel-Startseite mit verschiedenen Alpine.js-Komponenten hinzu
7. Initialisiert ein Git-Repository im erstellten Projekt

## Verwendung

```bash
./create-astro-project.sh [projektname]
```

### Parameter

- `projektname` (optional): Der Name des zu erstellenden Projekts. Wenn nicht angegeben, wird "astro-project" verwendet.

### Beispiel

```bash
# Erstellt ein Projekt mit dem Namen "meine-webseite"
./create-astro-project.sh meine-webseite

# Erstellt ein Projekt mit dem Standardnamen "astro-project"
./create-astro-project.sh
```

## Ausgabe

Das Skript erstellt das Projekt im `/dist`-Verzeichnis. Nach Abschluss des Skripts kannst du:

```bash
# In das Projektverzeichnis wechseln
cd dist/[projektname]

# Den Entwicklungsserver starten
npm run dev
```

## Alpine.js-Integration

Das erstellte Projekt enthält:

- Eine vollständige Alpine.js-Integration über die offizielle Astro-Integration
- Eine Setup-Komponente unter `src/components/AlpineSetup.astro`
- Benutzerdefinierte Direktiven und Stores
- Beispiele für:
  - Counter-Komponente
  - Toggle-Komponente  
  - Alpine Store-Beispiel
  - Benutzerdefinierte Direktive

## Technische Details

### Projektstruktur

Das generierte Projekt hat folgende Struktur:

```
[projektname]/
├── src/
│   ├── components/
│   │   └── AlpineSetup.astro   # Alpine.js Konfiguration
│   ├── layouts/
│   │   └── Layout.astro        # Hauptlayout mit Alpine.js
│   └── pages/
│       └── index.astro         # Startseite mit Beispielen
├── astro.config.mjs            # Astro-Konfiguration
├── package.json
├── .gitignore
└── README.md
``` 