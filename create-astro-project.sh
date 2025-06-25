#!/bin/bash

# Fehlerbehandlung aktivieren
set -e

# Projektname als Parameter oder Standardwert
PROJECT_NAME=${1:-"astro-project"}

echo "🚀 Erstelle neues Astro-Projekt: $PROJECT_NAME"

# 1. Prüfe, ob npm installiert ist
if ! command -v npm &> /dev/null; then
    echo "❌ npm ist nicht installiert. Bitte installiere Node.js und npm."
    exit 1
fi

# 2. Erstelle dist-Verzeichnis, falls es nicht existiert
echo "📁 Erstelle Ausgabeverzeichnis..."
mkdir -p dist

# 3. Astro-Projekt erstellen
echo "📦 Erstelle Astro-Projekt in dist/$PROJECT_NAME..."
cd dist
npm create astro@latest "$PROJECT_NAME" -- --template minimal --no-install --no

# In das Projektverzeichnis wechseln
cd "$PROJECT_NAME"

# 4. Abhängigkeiten installieren
echo "📥 Installiere Basis-Abhängigkeiten..."
npm install

# 5. Custom Packages installieren
echo "📥 Installiere Custom-Packages..."
npm install @casoon/dragonfly @casoon/astro-components alpinejs @astrojs/alpinejs @astrojs/mdx lightningcss

# 6. Astro Integrationen in Config einfügen
echo "🔧 Konfiguriere astro.config.mjs..."

cat > astro.config.mjs <<EOF
import { defineConfig } from 'astro/config';
import mdx from '@astrojs/mdx';
import alpinejs from '@astrojs/alpinejs';

// Bestimme ob Produktionsmodus
const isProduction = process.env.NODE_ENV === 'production';

export default defineConfig({
  integrations: [
    mdx(),
    alpinejs(),
  ],
  vite: {
    plugins: [],
    css: {
      transformer: 'lightningcss',
      lightningcss: {
        // Lightning CSS Optionen hier
        drafts: {
          nesting: true,
          customMedia: true,
          customProperties: true,
        },
        minify: true,
        verbose: !isProduction, // Detaillierte Ausgabe nur in Entwicklung
      },
      devSourcemap: !isProduction, // Sourcemaps nur in Entwicklung
    },
    logLevel: isProduction ? 'error' : 'info', // Log-Level basierend auf Umgebung
    build: {
      cssCodeSplit: true,
      cssMinify: true,
      logLevel: 'error',
    }
  },
  logger: {
    level: isProduction ? 'error' : 'info',
  }
});
EOF

# 7. Alpine.js Setup erstellen
echo "🏔️ Konfiguriere Alpine.js..."
mkdir -p src/components
cat > src/components/AlpineSetup.astro <<EOF
---
// AlpineSetup.astro - Komponent zum Einbinden von benutzerdefinierten Alpine.js-Funktionen
---

<script>
  import Alpine from 'alpinejs';

  // Alpine global verfügbar machen
  window.Alpine = Alpine;

  // Benutzerdefinierte Direktive
  Alpine.directive('highlight', (el) => {
    el.style.backgroundColor = 'yellow';
  });

  // Benutzerdefinierter Store
  Alpine.store('theme', {
    dark: false,
    toggle() {
      this.dark = !this.dark;
    }
  });

  // Starte Alpine
  Alpine.start();
</script>
EOF

# 8. Beispiel-Layout mit Alpine erstellen
mkdir -p src/layouts
cat > src/layouts/Layout.astro <<EOF
---
import { ViewTransitions } from 'astro:transitions';
import AlpineSetup from '../components/AlpineSetup.astro';
import '../styles/global.css';

export interface Props {
  title: string;
}

const { title } = Astro.props;
---

<!DOCTYPE html>
<html lang="de">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width" />
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
    <meta name="generator" content={Astro.generator} />
    <title>{title}</title>
    <ViewTransitions />
    <AlpineSetup />
  </head>
  <body class="min-h-screen" x-data="{ darkMode: false }">
    <div class="container px-5 py-3" x-bind:class="darkMode ? 'bg-gray-900 text-white' : 'bg-white text-gray-900'">
      <header class="pb-4">
        <div class="flex justify-between items-center">
          <h1 class="text-2xl font-bold">Astro + Alpine.js</h1>
          <button 
            @click="darkMode = !darkMode"
            class="px-3 py-1 rounded-md"
            x-bind:class="darkMode ? 'bg-white text-gray-900' : 'bg-gray-900 text-white'"
          >
            <span x-show="!darkMode">🌙 Dark</span>
            <span x-show="darkMode">☀️ Light</span>
          </button>
        </div>
      </header>
      <main>
        <slot />
      </main>
      <footer class="mt-8 pt-4 border-t text-sm">
        <p>Erstellt mit Astro und Alpine.js</p>
      </footer>
    </div>
  </body>
</html>
EOF

# 9. Beispiel-Seite mit Alpine.js-Komponenten
mkdir -p src/pages
cat > src/pages/index.astro <<EOF
---
import Layout from '../layouts/Layout.astro';
---

<Layout title="Alpine.js Beispiele">
  <h2 class="text-xl font-semibold mb-4">Alpine.js Beispiele</h2>
  
  <div class="space-y-8">
    <!-- Einfacher Counter -->
    <div class="p-4 border rounded-md" x-data="{ count: 0 }">
      <h3 class="font-medium mb-2">Counter Beispiel</h3>
      <div class="flex items-center space-x-4">
        <button 
          @click="count--" 
          class="px-3 py-1 bg-red-500 text-white rounded-md"
        >
          -
        </button>
        <span x-text="count" class="text-xl"></span>
        <button 
          @click="count++" 
          class="px-3 py-1 bg-green-500 text-white rounded-md"
        >
          +
        </button>
      </div>
    </div>
    
    <!-- Toggle Beispiel -->
    <div class="p-4 border rounded-md" x-data="{ open: false }">
      <h3 class="font-medium mb-2">Toggle Beispiel</h3>
      <button 
        @click="open = !open" 
        class="px-3 py-1 bg-blue-500 text-white rounded-md mb-2"
      >
        Toggle Content
      </button>
      <div x-show="open" x-transition class="p-3 bg-gray-100 rounded-md mt-2">
        Dieser Inhalt kann ein- und ausgeblendet werden.
      </div>
    </div>
    
    <!-- Alpine Store Beispiel -->
    <div class="p-4 border rounded-md">
      <h3 class="font-medium mb-2">Alpine Store Beispiel</h3>
      <div>
        <p>Theme Store Status: <span x-text="$store.theme.dark ? 'Dark' : 'Light'"></span></p>
        <button 
          @click="$store.theme.toggle()" 
          class="px-3 py-1 bg-purple-500 text-white rounded-md mt-2"
        >
          Theme umschalten
        </button>
      </div>
    </div>
    
    <!-- Direktiven Beispiel -->
    <div class="p-4 border rounded-md">
      <h3 class="font-medium mb-2">Custom Direktive</h3>
      <p x-highlight>Dieser Text wird mit der x-highlight Direktive markiert.</p>
    </div>
  </div>
</Layout>
EOF

# 10. Erstelle .gitignore Datei
echo "📝 Erstelle .gitignore..."
cat > .gitignore <<EOF
# Betriebssystem-Dateien
.DS_Store
Thumbs.db
desktop.ini

# Node.js spezifisch
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
package-lock.json
yarn.lock

# Build-Ausgaben
dist/
.output/
.astro/

# Temporäre Dateien
*.tmp
*.log
*.swp
*~

# Editor-Verzeichnisse und Dateien
.vscode/
.idea/
*.sublime-project
*.sublime-workspace

# Umgebungsvariablen
.env
.env.local
.env.development
.env.production
EOF

# 11. Erstelle eine einfache README.md
echo "📝 Erstelle README.md..."
cat > README.md <<EOF
# $PROJECT_NAME

Ein Astro-Projekt mit @casoon/dragonfly, @casoon/astro-components, Alpine.js und Lightning CSS.

## Entwicklung

\`\`\`bash
# Dev-Server starten
npm run dev

# Build für Produktion
npm run build
\`\`\`

## Alpine.js

Dieses Projekt verwendet Alpine.js für interaktive Komponenten:

- Alpine.js ist über die offizielle @astrojs/alpinejs Integration eingebunden
- Die Alpine.js-Konfiguration befindet sich in \`src/components/AlpineSetup.astro\`
- Alpine-Direktiven können in allen Astro-Komponenten verwendet werden
- Beispiele findest du auf der Startseite

## Lightning CSS

Dieses Projekt verwendet Lightning CSS für optimierte CSS-Verarbeitung:

- Lightning CSS ist als Vite-Plugin konfiguriert
- Unterstützt moderne CSS-Features wie Nesting und Custom Media Queries
- CSS wird automatisch minimiert und optimiert
- Keine zusätzliche Konfiguration erforderlich
EOF

# 12. Erstelle ein Beispiel-CSS-File
echo "🎨 Erstelle globale CSS-Datei mit Lightning CSS Features..."
mkdir -p src/styles
cat > src/styles/global.css <<EOF
/* globale CSS-Datei mit Lightning CSS Features */

/* CSS Variablen */
:root {
  --color-primary: #4a56e2;
  --color-secondary: #6e44ff;
  --color-text: #333;
  --color-background: #fff;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 2rem;
}

/* Custom Media Queries (Lightning CSS Feature) */
@custom-media --viewport-sm (min-width: 640px);
@custom-media --viewport-md (min-width: 768px);
@custom-media --viewport-lg (min-width: 1024px);

/* CSS Nesting (Lightning CSS Feature) */
.card {
  padding: var(--spacing-md);
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  
  & h3 {
    color: var(--color-primary);
    margin-bottom: var(--spacing-sm);
  }
  
  & p {
    color: var(--color-text);
  }
}

/* Responsive mit Custom Media Queries */
.container {
  width: 100%;
  padding: var(--spacing-md);
  
  @media (--viewport-md) {
    max-width: 768px;
    margin: 0 auto;
  }
  
  @media (--viewport-lg) {
    max-width: 1024px;
  }
}
EOF

# 13. Erstelle tasks.md im Hauptverzeichnis
echo "📋 Erstelle tasks.md mit Design-Vorgaben..."
cat > tasks.md <<EOF
# Casoon UI Design-Vorgaben

- **Grundlage:** Immer Casoon UI Lib verwenden (\`dragonfly\`).
- **Layer:** Vorhandene CSS-Layer und Utility-Klassen nutzen.
- **Eigene Styles:** Nur falls nötig, in eigenem \`@layer my-custom-layer\` ergänzen.
- **Design Tokens:** Farben, Abstände, Typografie etc. ausschließlich über Design Tokens steuern.
- **Komponenten:** Bestehende Module verwenden oder sauber neue Module anlegen.
- **Layout:** Grid, Flex und Container-Queries des Casoon-Systems verwenden.
- **Dokumentation:** Neue Utilities oder Module kurz beschreiben.

**Wichtig:**  
Keine Überschreibung von bestehenden Casoon-Styles ohne triftigen Grund.
Minimal zusätzliche CSS-Regeln schreiben.
EOF

# 14. Git Repository initialisieren (optional)
echo "🔧 Initialisiere Git Repository..."
git init
git add .
git commit -m "Initial commit: Astro-Projekt mit Alpine.js und Lightning CSS"

# Zurück zum Ursprungsverzeichnis
cd ../../

echo "✅ Setup abgeschlossen!"
echo "✨ Lightning CSS wurde hinzugefügt und konfiguriert"
echo "💡 Wechsle in dein Projektverzeichnis: cd dist/$PROJECT_NAME"
echo "🚀 Starte den Dev-Server mit: npm run dev"
