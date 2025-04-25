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
npm install @casoon/ui-lib @casoon/astro-components alpinejs @astrojs/alpinejs @astrojs/mdx

# 6. Astro Integrationen in Config einfügen
echo "🔧 Konfiguriere astro.config.mjs..."

cat > astro.config.mjs <<EOF
import { defineConfig } from 'astro/config';
import mdx from '@astrojs/mdx';
import alpinejs from '@astrojs/alpinejs';

export default defineConfig({
  integrations: [
    mdx(),
    alpinejs(),
  ],
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
    <div class="px-5 py-3" x-bind:class="darkMode ? 'bg-gray-900 text-white' : 'bg-white text-gray-900'">
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

Ein Astro-Projekt mit @casoon/ui-lib, @casoon/astro-components und Alpine.js.

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
EOF

# 12. Git Repository initialisieren (optional)
echo "🔧 Initialisiere Git Repository..."
git init
git add .
git commit -m "Initial commit: Astro-Projekt mit Alpine.js"

# Zurück zum Ursprungsverzeichnis
cd ../../

echo "✅ Setup abgeschlossen!"
echo "💡 Wechsle in dein Projektverzeichnis: cd dist/$PROJECT_NAME"
echo "🚀 Starte den Dev-Server mit: npm run dev"
