# Justfile for Zola and Tailwind CSS blog

set shell := ["bash", "-c"]

# List all available recipes
default:
    @just --list

# Install tools, package dependencies, and the pinned theme
setup: setup-tools install-theme

# Install the mise toolchain and Node dependencies
setup-tools: setup-toolchain install-dependencies

# Install the pinned toolchain from mise.toml
setup-toolchain:
    mise install

# Install Node dependencies from the lockfile
install-dependencies:
    pnpm install --frozen-lockfile

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

# Build and serve the site locally, then scan every generated HTML page for WCAG 2.0 AA issues
check-a11y-compliance: build
    @set -euo pipefail; \
    port=1112; \
    base_url="http://127.0.0.1:$port"; \
    config_file=$(mktemp); \
    zola serve --interface 127.0.0.1 --port "$port" --base-url "$base_url" --no-port-append --force & \
    server_pid=$!; \
    trap 'kill "$server_pid" 2>/dev/null || true; wait "$server_pid" 2>/dev/null || true; rm -f "$config_file"' EXIT; \
    for attempt in {1..30}; do \
        if ! kill -0 "$server_pid" 2>/dev/null; then wait "$server_pid"; exit 1; fi; \
        if curl --silent --fail "$base_url/" >/dev/null; then break; fi; \
        sleep 1; \
    done; \
    curl --silent --show-error --fail "$base_url/" >/dev/null || { echo "Zola did not become ready at $base_url" >&2; exit 1; }; \
    curl --silent --show-error --fail "$base_url/tailwind.css" >/dev/null; \
    curl --silent --show-error --fail "$base_url/main.css" >/dev/null; \
    node -e 'const fs = require("node:fs"); const path = require("node:path"); const walk = dir => fs.readdirSync(dir, { withFileTypes: true }).flatMap(entry => { const file = path.join(dir, entry.name); return entry.isDirectory() ? walk(file) : [file]; }); const urls = walk("public").filter(file => file.endsWith(".html")).map(file => "http://127.0.0.1:1112/" + file.slice("public/".length).replace(/index\.html$/, "")); if (!urls.length) throw new Error("No generated HTML pages found in public/"); const config = JSON.parse(fs.readFileSync(".pa11yci.local", "utf8")); fs.writeFileSync(process.argv[1], JSON.stringify({ ...config, urls }));' "$config_file"; \
    npx --yes pa11y-ci --config "$config_file"

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
