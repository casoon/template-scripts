#!/bin/bash

# Fehlerbehandlung aktivieren
set -e

PROJECT_NAME=${1:-"astro-motion-template"}

echo "🚀 Erstelle Astro Projekt: $PROJECT_NAME im dist Ordner"

# Voraussetzungen prüfen
if ! command -v npm &> /dev/null; then
  echo "❌ npm nicht gefunden. Bitte Node.js installieren."
  exit 1
fi

# dist Verzeichnis erstellen falls es nicht existiert
mkdir -p dist

# Astro-Projekt im dist Verzeichnis erstellen
cd dist
npm create astro@latest "$PROJECT_NAME" -- --template minimal --no-install --no-git --skip-houston --yes

# In das Projektverzeichnis wechseln
cd "$PROJECT_NAME"

# Abhängigkeiten installieren
npm install
npm install \
  @astrojs/mdx@latest \
  @astrojs/svelte@latest \
  @astrojs/tailwind@latest \
  @fontsource/roboto@latest \
  @tailwindcss/typography@latest \
  astro@latest \
  clsx@latest \
  gsap@latest \
  lucide-react@latest \
  motion@latest \
  svelte@latest \
  tailwind-merge@latest \
  tailwindcss@latest

# Astro-Konfiguration
cat > astro.config.mjs << 'EOF'
import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';
import mdx from '@astrojs/mdx';
import svelte from '@astrojs/svelte';

export default defineConfig({
  integrations: [
    tailwind({ 
      applyBaseStyles: false,
    }),
    svelte(),
    mdx(),
  ],
  build: {
    inlineStylesheets: 'auto',
  }
});
EOF

# Tailwind-Konfiguration
cat > tailwind.config.js << 'EOF'
export default {
  content: ["./src/**/*.{astro,html,js,jsx,ts,tsx,mdx}"],
  theme: {
    extend: {
      colors: {
        primary: {
          500: "rgb(var(--color-primary-500) / <alpha-value>)"
        },
        secondary: {
          500: "rgb(var(--color-secondary-500) / <alpha-value>)"
        },
        accent: {
          500: "rgb(var(--color-accent-500) / <alpha-value>)"
        }
      }
    }
  },
  plugins: [require('@tailwindcss/typography')]
};
EOF

# Global CSS mit Farbdefinitionen
mkdir -p src/styles
cat > src/styles/global.css << 'EOF'
@import "@fontsource/roboto/latin.css";
@import 'tailwindcss';

@layer base {
  :root {
    --color-primary-500: 230 20 77;
    --color-secondary-500: 51 51 51;
    --color-accent-500: 255 138 101;
  }
}
EOF

# Layout-Datei
mkdir -p src/layouts
cat > src/layouts/Layout.astro << 'EOF'
---
import "../styles/global.css";
---
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Astro Motion Template</title>
  </head>
  <body>
    <slot />
  </body>
</html>
EOF

# Beispielseite mit Motion
mkdir -p src/pages
cat > src/pages/index.astro << 'EOF'
---
import Layout from "../layouts/Layout.astro";
---
<Layout>
  <div
    id="welcome"
    class="text-center mt-16 text-4xl font-bold text-primary-500"
  >
    Willkommen zu Astro + Tailwind + Motion!
  </div>

  <div class="mt-10 text-center">
    <button id="clickme" class="bg-accent-500 text-white px-6 py-3 rounded-lg">
      Klick mich
    </button>
  </div>

  <script type="module">
    import { animate } from "motion";
    
    // Eingangsanimation
    animate("#welcome", 
      { opacity: [0, 1], y: [-20, 0] }, 
      { duration: 0.6 }
    );
    
    // Button-Interaktion
    document.getElementById("clickme").addEventListener("click", () => {
      animate("#clickme", { scale: [1, 1.2, 1] }, { duration: 0.4 });
    });
  </script>
</Layout>
EOF

# Utils-Verzeichnis und index.ts anlegen
mkdir -p src/utils
cat > src/utils/index.ts << 'EOF'
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
EOF

# package.json Scripts setzen
npm pkg set scripts.dev="astro dev"
npm pkg set scripts.build="astro build"
npm pkg set scripts.preview="astro preview"

echo "✅ Projekt $PROJECT_NAME im dist Ordner erstellt!"
echo "👉 cd dist/$PROJECT_NAME && npm run dev"
