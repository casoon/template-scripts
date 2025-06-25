#!/bin/bash

# Fehlerbehandlung aktivieren
set -e

# =============================================================================
# KONFIGURATION - Hier können alle Design-Parameter angepasst werden
# =============================================================================

# Projekt-Konfiguration
PROJECT_NAME=${1:-"casoon-homepage"}
COMPANY_NAME="CASOON"
TAGLINE="Freelancer für moderne Webentwicklung & digitale Lösungen"

# Farbschema (vordefinierte Paletten oder individuelle Hex-Codes)
COLOR_THEME="modern"              # warm, elegant, modern, minimal oder "" für individuelle Farben
PRIMARY_COLOR="#E6144D"         # Wird nur verwendet wenn COLOR_THEME="" ist
SECONDARY_COLOR="#333333"       # Wird nur verwendet wenn COLOR_THEME="" ist  
ACCENT_COLOR="#FF8A65"          # Wird nur verwendet wenn COLOR_THEME="" ist

# Typografie-Konfiguration
MAIN_FONT="inter"          # Hauptschrift
MONO_FONT="jetbrains-mono"  # Monospace-Schrift

# Layout & Navigation
MAX_WIDTH="6xl"            # Container max-width
BORDER_RADIUS="lg"         # Standard Border-Radius
NAVIGATION_STYLE="sticky"  # fixed, sticky, static

# Social Media Links
EMAIL="hello@casoon.com"
GITHUB_URL="https://github.com/username"
LINKEDIN_URL="https://linkedin.com/in/username"
TWITTER_URL="https://twitter.com/username"

# =============================================================================
# FUNKTIONEN
# =============================================================================

# Vordefinierte Farbpaletten
get_predefined_colors() {
    case "$1" in
        "warm")
            PRIMARY_COLOR="#E6144D"
            SECONDARY_COLOR="#333333" 
            ACCENT_COLOR="#FF8A65"
            ;;
        "elegant")
            PRIMARY_COLOR="#E6144D"
            SECONDARY_COLOR="#2C2C2C"
            ACCENT_COLOR="#CDA27E"
            ;;
        "modern")
            PRIMARY_COLOR="#E6144D"
            SECONDARY_COLOR="#424242"
            ACCENT_COLOR="#00ACC1"
            ;;
        "minimal")
            PRIMARY_COLOR="#E6144D"
            SECONDARY_COLOR="#1A1A1A"
            ACCENT_COLOR="#6D6D6D"
            ;;
    esac
}

# Hex zu RGB konvertieren
hex_to_rgb() {
    local hex=${1#"#"}
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    echo "$r $g $b"
}

# Farbpalette generieren
generate_color_vars() {
    local color=$1
    local name=$2
    local rgb=$(hex_to_rgb "$color")
    local r=$(echo $rgb | cut -d' ' -f1)
    local g=$(echo $rgb | cut -d' ' -f2)
    local b=$(echo $rgb | cut -d' ' -f3)
    
    echo "    --color-$name-50: $((r + (255-r)*95/100)) $((g + (255-g)*95/100)) $((b + (255-b)*95/100));"
    echo "    --color-$name-100: $((r + (255-r)*85/100)) $((g + (255-g)*85/100)) $((b + (255-b)*85/100));"
    echo "    --color-$name-200: $((r + (255-r)*70/100)) $((g + (255-g)*70/100)) $((b + (255-b)*70/100));"
    echo "    --color-$name-300: $((r + (255-r)*50/100)) $((g + (255-g)*50/100)) $((b + (255-b)*50/100));"
    echo "    --color-$name-400: $((r + (255-r)*25/100)) $((g + (255-g)*25/100)) $((b + (255-b)*25/100));"
    echo "    --color-$name-500: $r $g $b;"
    echo "    --color-$name-600: $((r*85/100)) $((g*85/100)) $((b*85/100));"
    echo "    --color-$name-700: $((r*70/100)) $((g*70/100)) $((b*70/100));"
    echo "    --color-$name-800: $((r*55/100)) $((g*55/100)) $((b*55/100));"
    echo "    --color-$name-900: $((r*40/100)) $((g*40/100)) $((b*40/100));"
    echo "    --color-$name-950: $((r*25/100)) $((g*25/100)) $((b*25/100));"
}

# =============================================================================
# SCRIPT START
# =============================================================================

echo "🚀 Erstelle $COMPANY_NAME Homepage: $PROJECT_NAME"

# Farbthema anwenden
if [ -n "$COLOR_THEME" ]; then
    echo "🎨 Verwende Farbthema: $COLOR_THEME"
    get_predefined_colors "$COLOR_THEME"
else
    echo "🎨 Verwende individuelle Farben"
fi

# 1. Prüfe npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm nicht gefunden. Bitte Node.js installieren."
    exit 1
fi

# 2. Erstelle Projektverzeichnis
mkdir -p dist
cd dist

# 3. Astro-Projekt erstellen
echo "📦 Erstelle Astro-Projekt..."
npm create astro@latest "$PROJECT_NAME" -- --template minimal --no-install --no
cd "$PROJECT_NAME"

# 4. Dependencies installieren
echo "📥 Installiere Dependencies..."
npm install

# 5. Design-Packages installieren (stabile Versionen)
echo "📥 Installiere Design-Dependencies..."
npm install @astrojs/tailwind@^5.1.0 @astrojs/alpinejs@^0.4.0 tailwindcss@^3.4.0 alpinejs@^3.14.0 @tailwindcss/typography@^0.5.0 @fontsource/inter @fontsource/jetbrains-mono --legacy-peer-deps

# 6. Astro Config (saubere Lösung ohne PostCSS Konflikte)
echo "🔧 Konfiguriere Astro..."
cat > astro.config.mjs << 'ASTRO_EOF'
import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';
import alpinejs from '@astrojs/alpinejs';

export default defineConfig({
  integrations: [
    tailwind({ 
      applyBaseStyles: false,
    }),
    alpinejs(),
  ],
  build: {
    inlineStylesheets: 'auto',
  }
});
ASTRO_EOF

# 7. Tailwind Config
echo "🎨 Konfiguriere Tailwind..."
cat > tailwind.config.mjs << 'TAILWIND_EOF'
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  theme: {
    extend: {
      colors: {
        primary: {
          50: 'rgb(var(--color-primary-50) / <alpha-value>)',
          100: 'rgb(var(--color-primary-100) / <alpha-value>)',
          200: 'rgb(var(--color-primary-200) / <alpha-value>)',
          300: 'rgb(var(--color-primary-300) / <alpha-value>)',
          400: 'rgb(var(--color-primary-400) / <alpha-value>)',
          500: 'rgb(var(--color-primary-500) / <alpha-value>)',
          600: 'rgb(var(--color-primary-600) / <alpha-value>)',
          700: 'rgb(var(--color-primary-700) / <alpha-value>)',
          800: 'rgb(var(--color-primary-800) / <alpha-value>)',
          900: 'rgb(var(--color-primary-900) / <alpha-value>)',
          950: 'rgb(var(--color-primary-950) / <alpha-value>)',
        },
        secondary: {
          50: 'rgb(var(--color-secondary-50) / <alpha-value>)',
          100: 'rgb(var(--color-secondary-100) / <alpha-value>)',
          200: 'rgb(var(--color-secondary-200) / <alpha-value>)',
          300: 'rgb(var(--color-secondary-300) / <alpha-value>)',
          400: 'rgb(var(--color-secondary-400) / <alpha-value>)',
          500: 'rgb(var(--color-secondary-500) / <alpha-value>)',
          600: 'rgb(var(--color-secondary-600) / <alpha-value>)',
          700: 'rgb(var(--color-secondary-700) / <alpha-value>)',
          800: 'rgb(var(--color-secondary-800) / <alpha-value>)',
          900: 'rgb(var(--color-secondary-900) / <alpha-value>)',
          950: 'rgb(var(--color-secondary-950) / <alpha-value>)',
        },
        accent: {
          50: 'rgb(var(--color-accent-50) / <alpha-value>)',
          100: 'rgb(var(--color-accent-100) / <alpha-value>)',
          200: 'rgb(var(--color-accent-200) / <alpha-value>)',
          300: 'rgb(var(--color-accent-300) / <alpha-value>)',
          400: 'rgb(var(--color-accent-400) / <alpha-value>)',
          500: 'rgb(var(--color-accent-500) / <alpha-value>)',
          600: 'rgb(var(--color-accent-600) / <alpha-value>)',
          700: 'rgb(var(--color-accent-700) / <alpha-value>)',
          800: 'rgb(var(--color-accent-800) / <alpha-value>)',
          900: 'rgb(var(--color-accent-900) / <alpha-value>)',
          950: 'rgb(var(--color-accent-950) / <alpha-value>)',
        }
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'Menlo', 'monospace'],
      }
    },
  },
  plugins: [require('@tailwindcss/typography')],
}
TAILWIND_EOF

# 8. CSS mit generierten Farben erstellen (ohne import statements)
echo "🎨 Erstelle CSS mit $COLOR_THEME Farben..."
mkdir -p src/styles

cat > src/styles/global.css << CSS_EOF
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
$(generate_color_vars "$PRIMARY_COLOR" "primary")
$(generate_color_vars "$SECONDARY_COLOR" "secondary")
$(generate_color_vars "$ACCENT_COLOR" "accent")
  }
  
  html {
    font-family: Inter, system-ui, sans-serif;
    scroll-behavior: smooth;
  }
  
  body {
    @apply text-secondary-900 bg-white antialiased;
  }
  
  h1, h2, h3, h4, h5, h6 {
    @apply font-semibold leading-tight;
  }
  
  h1 { @apply text-4xl md:text-5xl lg:text-6xl; }
  h2 { @apply text-3xl md:text-4xl; }
  h3 { @apply text-2xl md:text-3xl; }
}

@layer components {
  .btn {
    @apply px-6 py-3 rounded-lg font-medium transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 inline-flex items-center justify-center;
  }
  
  .btn-primary {
    @apply btn bg-primary-600 text-white hover:bg-primary-700 focus:ring-primary-500 shadow-sm;
  }
  
  .btn-secondary {
    @apply btn bg-secondary-200 text-secondary-900 hover:bg-secondary-300 focus:ring-secondary-500;
  }
  
  .btn-outline {
    @apply btn border-2 border-primary-600 text-primary-600 hover:bg-primary-600 hover:text-white focus:ring-primary-500;
  }
  
  .card {
    @apply bg-white rounded-lg shadow-sm border border-secondary-200 p-6 transition-shadow duration-200;
  }
  
  .card-hover {
    @apply card hover:shadow-md;
  }
  
  .container-custom {
    @apply max-w-6xl mx-auto px-4 sm:px-6 lg:px-8;
  }
  
  .section-padding {
    @apply py-16 md:py-20;
  }
}
CSS_EOF

# 9. Alpine.js Setup
echo "🏔️ Erstelle Alpine.js Setup..."
mkdir -p src/components

cat > src/components/AlpineSetup.astro << 'ALPINE_EOF'
<script>
  import Alpine from 'alpinejs';

  window.Alpine = Alpine;

  Alpine.store('navigation', {
    isOpen: false,
    toggle() { this.isOpen = !this.isOpen; },
    close() { this.isOpen = false; }
  });

  Alpine.data('contactForm', () => ({
    name: '', email: '', message: '',
    isSubmitting: false, isSubmitted: false,
    
    async submitForm() {
      this.isSubmitting = true;
      await new Promise(resolve => setTimeout(resolve, 1000));
      this.isSubmitted = true;
      this.isSubmitting = false;
      
      setTimeout(() => {
        this.isSubmitted = false;
        this.name = this.email = this.message = '';
      }, 3000);
    }
  }));

  Alpine.directive('smooth-scroll', (el) => {
    el.addEventListener('click', (e) => {
      const href = el.getAttribute('href');
      if (href && href.startsWith('#')) {
        e.preventDefault();
        const target = document.querySelector(href);
        if (target) {
          target.scrollIntoView({ behavior: 'smooth' });
          Alpine.store('navigation').close();
        }
      }
    });
  });

  Alpine.start();
</script>
ALPINE_EOF

# 10. Layout erstellen
mkdir -p src/layouts

cat > src/layouts/Layout.astro << 'LAYOUT_EOF'
---
import AlpineSetup from '../components/AlpineSetup.astro';
import '../styles/global.css';

export interface Props {
  title: string;
  description?: string;
}

const { title, description = 'Freelancer für moderne Webentwicklung & digitale Lösungen' } = Astro.props;
---

<!DOCTYPE html>
<html lang="de">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content={description} />
    <meta name="generator" content={Astro.generator} />
    
    <!-- Font imports direkt im HTML -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
    
    <title>{title}</title>
    <AlpineSetup />
  </head>
  <body class="min-h-screen">
    <slot />
  </body>
</html>
LAYOUT_EOF

# 11. Navigation erstellen
cat > src/components/Navigation.astro << 'NAV_EOF'
<nav class="sticky top-0 z-50 bg-white/95 backdrop-blur-sm shadow-sm border-b border-secondary-200">
  <div class="container-custom">
    <div class="flex justify-between items-center h-16">
      <div class="flex-shrink-0">
        <a href="/" class="text-2xl font-bold text-primary-600">CASOON</a>
      </div>
      
      <div class="hidden md:flex items-center space-x-8">
        <a href="#home" x-smooth-scroll class="text-secondary-700 hover:text-primary-600 transition-colors">Home</a>
        <a href="#services" x-smooth-scroll class="text-secondary-700 hover:text-primary-600 transition-colors">Services</a>
        <a href="#portfolio" x-smooth-scroll class="text-secondary-700 hover:text-primary-600 transition-colors">Portfolio</a>
        <a href="#about" x-smooth-scroll class="text-secondary-700 hover:text-primary-600 transition-colors">Über mich</a>
        <a href="#contact" x-smooth-scroll class="btn-primary">Kontakt</a>
      </div>
      
      <div class="md:hidden">
        <button @click="$store.navigation.toggle()" class="text-secondary-700 hover:text-primary-600 p-2">
          <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
          </svg>
        </button>
      </div>
    </div>
  </div>
  
  <div x-show="$store.navigation.isOpen" x-transition class="md:hidden bg-white border-t border-secondary-200">
    <div class="px-2 pt-2 pb-3 space-y-1">
      <a href="#home" @click="$store.navigation.close()" x-smooth-scroll class="block px-3 py-2 text-base font-medium text-secondary-700 hover:text-primary-600 hover:bg-secondary-50 rounded transition-colors">Home</a>
      <a href="#services" @click="$store.navigation.close()" x-smooth-scroll class="block px-3 py-2 text-base font-medium text-secondary-700 hover:text-primary-600 hover:bg-secondary-50 rounded transition-colors">Services</a>
      <a href="#portfolio" @click="$store.navigation.close()" x-smooth-scroll class="block px-3 py-2 text-base font-medium text-secondary-700 hover:text-primary-600 hover:bg-secondary-50 rounded transition-colors">Portfolio</a>
      <a href="#about" @click="$store.navigation.close()" x-smooth-scroll class="block px-3 py-2 text-base font-medium text-secondary-700 hover:text-primary-600 hover:bg-secondary-50 rounded transition-colors">Über mich</a>
      <a href="#contact" @click="$store.navigation.close()" x-smooth-scroll class="block px-3 py-2 text-base font-medium bg-primary-600 text-white rounded hover:bg-primary-700 transition-colors">Kontakt</a>
    </div>
  </div>
</nav>
NAV_EOF

# 12. Homepage erstellen  
cat > src/pages/index.astro << 'INDEX_EOF'
---
import Layout from '../layouts/Layout.astro';
import Navigation from '../components/Navigation.astro';
---

<Layout title="CASOON - Homepage">
  <Navigation />
  
  <!-- Hero Section -->
  <section id="home" class="bg-gradient-to-br from-primary-50 to-white section-padding">
    <div class="container-custom">
      <div class="max-w-4xl mx-auto text-center">
        <h1 class="mb-6">
          Hallo, ich bin <span class="text-primary-600">CASOON</span>
        </h1>
        <p class="text-xl text-secondary-600 mb-8">
          Freelancer für moderne Webentwicklung & digitale Lösungen
        </p>
        <div class="flex flex-col sm:flex-row gap-4 justify-center">
          <a href="#contact" x-smooth-scroll class="btn-primary">Projekt starten</a>
          <a href="#portfolio" x-smooth-scroll class="btn-outline">Portfolio ansehen</a>
        </div>
      </div>
    </div>
  </section>

  <!-- Services Section -->
  <section id="services" class="section-padding bg-white">
    <div class="container-custom">
      <div class="text-center mb-16">
        <h2 class="mb-4">Meine Services</h2>
        <p class="text-secondary-600 max-w-2xl mx-auto">
          Professionelle Webentwicklung und digitale Lösungen
        </p>
      </div>
      
      <div class="grid md:grid-cols-3 gap-8">
        <div class="card-hover text-center">
          <div class="w-16 h-16 bg-primary-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg class="w-8 h-8 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"></path>
            </svg>
          </div>
          <h3 class="mb-3">Webentwicklung</h3>
          <p class="text-secondary-600">Moderne, responsive Websites</p>
        </div>
        
        <div class="card-hover text-center">
          <div class="w-16 h-16 bg-accent-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg class="w-8 h-8 text-accent-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z"></path>
            </svg>
          </div>
          <h3 class="mb-3">App Development</h3>
          <p class="text-secondary-600">Progressive Web Apps</p>
        </div>
        
        <div class="card-hover text-center">
          <div class="w-16 h-16 bg-secondary-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg class="w-8 h-8 text-secondary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
            </svg>
          </div>
          <h3 class="mb-3">Performance</h3>
          <p class="text-secondary-600">Optimierung & SEO</p>
        </div>
      </div>
    </div>
  </section>

  <!-- Portfolio Section -->
  <section id="portfolio" class="section-padding bg-secondary-50">
    <div class="container-custom">
      <div class="text-center mb-16">
        <h2 class="mb-4">Portfolio</h2>
        <p class="text-secondary-600">Ausgewählte Projekte</p>
      </div>
      
      <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
        <div class="bg-white rounded-lg overflow-hidden shadow-sm hover:shadow-md transition-shadow">
          <div class="h-48 bg-gradient-to-br from-primary-400 to-primary-600"></div>
          <div class="p-6">
            <h3 class="font-semibold mb-2">E-Commerce Website</h3>
            <p class="text-secondary-600 text-sm mb-4">React & TypeScript</p>
            <div class="flex gap-2">
              <span class="px-2 py-1 bg-primary-100 text-primary-800 text-xs rounded">React</span>
              <span class="px-2 py-1 bg-primary-100 text-primary-800 text-xs rounded">TypeScript</span>
            </div>
          </div>
        </div>
        
        <div class="bg-white rounded-lg overflow-hidden shadow-sm hover:shadow-md transition-shadow">
          <div class="h-48 bg-gradient-to-br from-accent-400 to-accent-600"></div>
          <div class="p-6">
            <h3 class="font-semibold mb-2">Mobile App</h3>
            <p class="text-secondary-600 text-sm mb-4">React Native</p>
            <div class="flex gap-2">
              <span class="px-2 py-1 bg-accent-100 text-accent-800 text-xs rounded">React Native</span>
              <span class="px-2 py-1 bg-accent-100 text-accent-800 text-xs rounded">Node.js</span>
            </div>
          </div>
        </div>
        
        <div class="bg-white rounded-lg overflow-hidden shadow-sm hover:shadow-md transition-shadow">
          <div class="h-48 bg-gradient-to-br from-secondary-400 to-secondary-600"></div>
          <div class="p-6">
            <h3 class="font-semibold mb-2">Corporate Website</h3>
            <p class="text-secondary-600 text-sm mb-4">Astro & Tailwind</p>
            <div class="flex gap-2">
              <span class="px-2 py-1 bg-secondary-100 text-secondary-800 text-xs rounded">Astro</span>
              <span class="px-2 py-1 bg-secondary-100 text-secondary-800 text-xs rounded">Tailwind</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- About Section -->
  <section id="about" class="section-padding bg-white">
    <div class="container-custom">
      <div class="grid lg:grid-cols-2 gap-12 items-center">
        <div>
          <h2 class="mb-6">Über mich</h2>
          <p class="text-secondary-600 mb-6 text-lg">
            Mit über X Jahren Erfahrung helfe ich Unternehmen dabei, 
            ihre digitalen Ziele zu erreichen.
          </p>
          <div class="space-y-4 mb-8">
            <div class="flex items-center">
              <div class="w-2 h-2 bg-primary-600 rounded-full mr-3"></div>
              <span class="text-secondary-700">Frontend & Backend Development</span>
            </div>
            <div class="flex items-center">
              <div class="w-2 h-2 bg-accent-600 rounded-full mr-3"></div>
              <span class="text-secondary-700">UI/UX Design</span>
            </div>
            <div class="flex items-center">
              <div class="w-2 h-2 bg-secondary-600 rounded-full mr-3"></div>
              <span class="text-secondary-700">Performance Optimierung</span>
            </div>
          </div>
          <a href="#contact" x-smooth-scroll class="btn-primary">Zusammenarbeiten</a>
        </div>
        <div class="lg:text-right">
          <div class="inline-block p-8 bg-gradient-to-br from-primary-50 to-accent-50 rounded-2xl">
            <div class="w-48 h-48 bg-white/50 rounded-full mx-auto flex items-center justify-center">
              <div class="w-32 h-32 bg-primary-200 rounded-full"></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- Contact Section -->
  <section id="contact" class="section-padding bg-secondary-50">
    <div class="container-custom">
      <div class="text-center mb-16">
        <h2 class="mb-4">Kontakt</h2>
        <p class="text-secondary-600">Bereit für Ihr nächstes Projekt?</p>
      </div>
      
      <div class="max-w-2xl mx-auto">
        <form x-data="contactForm" @submit.prevent="submitForm" class="card">
          <div class="grid md:grid-cols-2 gap-6 mb-6">
            <div>
              <label for="name" class="block text-sm font-medium text-secondary-700 mb-2">Name *</label>
              <input type="text" id="name" x-model="name" required
                     class="w-full px-4 py-3 border border-secondary-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent">
            </div>
            <div>
              <label for="email" class="block text-sm font-medium text-secondary-700 mb-2">E-Mail *</label>
              <input type="email" id="email" x-model="email" required
                     class="w-full px-4 py-3 border border-secondary-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent">
            </div>
          </div>
          
          <div class="mb-6">
            <label for="message" class="block text-sm font-medium text-secondary-700 mb-2">Nachricht *</label>
            <textarea id="message" x-model="message" rows="5" required
                      class="w-full px-4 py-3 border border-secondary-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"></textarea>
          </div>
          
          <div class="text-center">
            <button type="submit" class="btn-primary" :disabled="isSubmitting">
              <span x-show="!isSubmitting">Nachricht senden</span>
              <span x-show="isSubmitting">Wird gesendet...</span>
            </button>
            
            <div x-show="isSubmitted" x-transition class="mt-4 p-4 bg-accent-100 text-accent-800 rounded-lg">
              Vielen Dank! Ihre Nachricht wurde gesendet.
            </div>
          </div>
        </form>
      </div>
    </div>
  </section>

  <!-- Footer -->
  <footer class="bg-secondary-900 text-white section-padding">
    <div class="container-custom">
      <div class="text-center">
        <div class="text-2xl font-bold text-primary-400 mb-4">CASOON</div>
        <p class="text-secondary-400 mb-6">Freelancer für moderne Webentwicklung & digitale Lösungen</p>
        <div class="flex justify-center space-x-6 mb-8">
          <a href="https://github.com/username" class="text-secondary-400 hover:text-white transition-colors">
            <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 0C5.374 0 0 5.373 0 12 0 17.302 3.438 21.8 8.207 23.387c.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23A11.509 11.509 0 0112 5.803c1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576C20.566 21.797 24 17.3 24 12c0-6.627-5.373-12-12-12z"/>
            </svg>
          </a>
          <a href="https://linkedin.com/in/username" class="text-secondary-400 hover:text-white transition-colors">
            <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
              <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
            </svg>
          </a>
        </div>
        <div class="pt-8 border-t border-secondary-800 text-sm text-secondary-400">
          <p>&copy; 2025 CASOON. Alle Rechte vorbehalten.</p>
        </div>
      </div>
    </div>
  </footer>
</Layout>
INDEX_EOF

# 13. Package.json Scripts
echo "📝 Konfiguriere package.json..."
npm pkg set scripts.build="astro build"
npm pkg set scripts.dev="astro dev"
npm pkg set scripts.preview="astro preview"

# 14. .gitignore
cat > .gitignore << 'GITIGNORE_EOF'
# Dependencies
node_modules/
package-lock.json

# Build
dist/
.astro/
.output/

# Environment
.env*

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db
GITIGNORE_EOF

# 15. README
cat > README.md << README_EOF
# $COMPANY_NAME Homepage

Moderne Homepage mit Astro, Tailwind CSS und Alpine.js.

## 🎨 Design
- **Farbthema**: $COLOR_THEME
- **Primärfarbe**: $PRIMARY_COLOR
- **Sekundärfarbe**: $SECONDARY_COLOR  
- **Akzentfarbe**: $ACCENT_COLOR

## 🚀 Entwicklung

\`\`\`bash
npm run dev     # Development server
npm run build   # Production build
npm run preview # Preview build
\`\`\`

## 🎨 Farbthemen

Das Script unterstützt vordefinierte Farbthemen:

- **warm**: Warm & Klar (Pink-Orange)
- **elegant**: Elegant & Zurückhaltend (Pink-Bronze)
- **modern**: Modern & Lebendig (Pink-Cyan)
- **minimal**: Minimalistisch & Zeitlos (Pink-Grau)

## ⚙️ Anpassung

\`\`\`bash
# Anderes Farbthema
COLOR_THEME="elegant" ./create-casoon-homepage.sh elegant-site

# Individuelle Farben
COLOR_THEME="" PRIMARY_COLOR="#8b5cf6" ./create-casoon-homepage.sh custom-site
\`\`\`
README_EOF

# 16. Favicon
mkdir -p public
cat > public/favicon.svg << 'FAVICON_EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <defs>
    <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#E6144D;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#FF8A65;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="100" height="100" rx="20" fill="url(#grad)"/>
  <text x="50" y="65" font-family="Inter, sans-serif" font-size="40" font-weight="bold" text-anchor="middle" fill="white">C</text>
</svg>
FAVICON_EOF

# 17. Git initialisieren
echo "🔧 Initialisiere Git..."
git init
git add .
git commit -m "Initial commit: $COMPANY_NAME Homepage mit $COLOR_THEME Theme"

# 18. Build testen
echo "🧪 Teste Build..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Build erfolgreich!"
else
    echo "❌ Build-Fehler"
fi

# Zurück zum Ursprungsverzeichnis  
cd ../../

echo ""
echo "🎉 $COMPANY_NAME Homepage Setup abgeschlossen!"
echo ""
echo "📁 Projektverzeichnis: dist/$PROJECT_NAME"
echo "🚀 Nächste Schritte:"
echo "   cd dist/$PROJECT_NAME"
echo "   npm run dev"
echo ""
echo "🌐 Development Server: http://localhost:4321"
echo ""
echo "🎨 Design-Konfiguration:"
echo "   Farbthema: $COLOR_THEME"
echo "   Primärfarbe: $PRIMARY_COLOR"
echo "   Sekundärfarbe: $SECONDARY_COLOR"
echo "   Akzentfarbe: $ACCENT_COLOR"
echo ""
echo "✨ Features:"
echo "   ✓ Astro + Tailwind CSS + Alpine.js"
echo "   ✓ Vordefinierte Farbthemen ($COLOR_THEME)"
echo "   ✓ Responsive Design"
echo "   ✓ Mobile Navigation"
echo "   ✓ Smooth Scrolling"
echo "   ✓ Contact Form"
echo "   ✓ SEO-optimiert"
echo ""
echo "🔧 Andere Farbthemen testen:"
echo "   COLOR_THEME=\"elegant\" ./create-casoon-homepage.sh elegant-site"
echo "   COLOR_THEME=\"modern\" ./create-casoon-homepage.sh modern-site"
echo "   COLOR_THEME=\"minimal\" ./create-casoon-homepage.sh minimal-site"
echo ""