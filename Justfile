# Justfile for Zola and Tailwind CSS blog

set shell := ["bash", "-c"]

# List all available recipes
default:
    @just --list

# Install tools, package dependencies, and the pinned theme
setup:
    set -a; [ -f .env ] && source .env; set +a
    mise install
    pnpm install
    just install-theme

# Build Tailwind CSS for production (minified)
build-css:
    set -a; [ -f .env ] && source .env; set +a
    pnpm run build:css

# Watch and rebuild Tailwind CSS during development
watch-css:
    set -a; [ -f .env ] && source .env; set +a
    pnpm run watch:css

# Check the Zola site for errors
check:
    zola check

# Start the Zola local development server
serve:
    set -a; [ -f .env ] && source .env; set +a
    zola serve --interface "${INTERFACE:-127.0.0.1}" --port "${PORT:-1111}"

# Build the site for production (builds CSS then builds Zola site)
build: build-css
    set -a; [ -f .env ] && source .env; set +a
    zola build

# Start development environment (runs Tailwind CSS watcher and Zola server concurrently)
[parallel]
blog: watch-css serve

install-theme:
	set -euo pipefail; \
	git submodule update --init --recursive; \
	git -C themes/apollo fetch --quiet; \
	git -C themes/apollo checkout a4de2efcb2a49076022eb01744c37d3de6c05500; \
	git -C themes/apollo submodule update --init --recursive; \
	echo "themes/apollo pinned to commit a4de2efc"

# One-off admin tasks
regen-index:
	set -a; [ -f .env ] && source .env; set +a
	# Rebuild search index (Zola + any client-side index builder)
	zola build --output-dir public
	# If a JS-based search index build step exists, run it here (e.g. node script)
	# node scripts/build-search-index.js || true
	@echo "Index regenerated into public/"

audit-deps:
	pnpm audit --audit-level=high

# Format code with biome (JS/TS/JSON/TOML/CSS) and prettier (HTML templates)
format:
	set -a; [ -f .env ] && source .env; set +a
	@echo "Formatting code..."
	# Format with biome (JS, JSON, TOML)
	pnpm exec biome format --write . || true
	# Format HTML templates with prettier (if available)
	pnpm exec prettier --write "templates/**/*.html" "content/**/*.md" || true
	@echo "✓ Formatting complete"
