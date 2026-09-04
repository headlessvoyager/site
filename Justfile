# Justfile for Zola and Tailwind CSS blog

set shell := ["bash", "-c"]

# List all available recipes
default:
    @just --list

# Install all dependencies (mise and pnpm)
setup:
    set -a; [ -f .env ] && source .env; set +a
    mise install
    pnpm install || true

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

# Install platform-specific release assets for pinned tools using their
# sha256 digests (as recorded in mise.toml). Installs into ./tools/bin.
install-just:
	set -euo pipefail; \
	# If running in CI (ubuntu), default to linux x86_64 asset for speed; otherwise detect local OS/arch
	if [ -n "${CI:-}" ] || [ -n "${GITHUB_ACTIONS:-}" ]; then \
		asset="just-1.58.0-x86_64-unknown-linux-musl.tar.gz"; expected="4a5cc2f53e6f0f8c59092a6cc38291eb729d46a7dd95d3ae582008881b84931d"; \
	else \
		host_os=$(uname -s); arch=$(uname -m); \
		case "$host_os-$arch" in \
		"Linux-x86_64") asset="just-1.58.0-x86_64-unknown-linux-musl.tar.gz"; expected="4a5cc2f53e6f0f8c59092a6cc38291eb729d46a7dd95d3ae582008881b84931d";; \
		"Linux-aarch64"|"Linux-arm64") asset="just-1.58.0-aarch64-unknown-linux-musl.tar.gz"; expected="748237128c4c40cbdabc65e841d05ceba13cc23a91eaba395495894c1d9764df";; \
		"Darwin-x86_64") asset="just-1.58.0-x86_64-apple-darwin.tar.gz"; expected="9a09cfef66aaa79da58203970103a0684307716caaabd3e9844cacc4dc0f4023";; \
		"Darwin-arm64"|"Darwin-aarch64") asset="just-1.58.0-aarch64-apple-darwin.tar.gz"; expected="50ae3e996c974a0bf32ea7d10f495070df33f1b43e0616b2769e3d4821ed8f48";; \
		*) echo "Unsupported OS/arch: $host_os-$arch" >&2; exit 1;; \
		esac; \
	fi; \
	tmpdir=$(mktemp -d); url="https://github.com/casey/just/releases/download/1.58.0/$asset"; \
	echo "Downloading $url"; curl -fL "$url" -o "$tmpdir/archive.tar.gz"; \
	printf "%s  %s\n" "$expected" "$tmpdir/archive.tar.gz" > "$tmpdir/expected.sha"; \
	(sha256sum -c "$tmpdir/expected.sha" || shasum -a 256 -c "$tmpdir/expected.sha") || { echo "Checksum failed" >&2; exit 2; }; \
	mkdir -p tools/bin; tar -xzf "$tmpdir/archive.tar.gz" -C "$tmpdir"; \
	just_bin=$(find "$tmpdir" -type f -name just -perm -111 | head -n1 || true); \
	if [ -z "$just_bin" ]; then echo "just binary not found in archive" >&2; exit 3; fi; \
	cp "$just_bin" tools/bin/just; chmod +x tools/bin/just; rm -rf "$tmpdir";

install-pnpm:
	set -euo pipefail; \
	# On CI (ubuntu) use linux x64 asset to avoid platform mapping complexities
	if [ -n "${CI:-}" ] || [ -n "${GITHUB_ACTIONS:-}" ]; then \
		asset="pnpm-11.25.0-linux-x64.tar.gz"; expected="11caeed8b581d460638f836f10f6ead19cbf08d774a5b8e502628b20ebf3ac43"; \
	else \
		host_os=$(uname -s); arch=$(uname -m); \
		case "$host_os-$arch" in \
		"Linux-x86_64") asset="pnpm-11.25.0-linux-x64.tar.gz"; expected="11caeed8b581d460638f836f10f6ead19cbf08d774a5b8e502628b20ebf3ac43";; \
		"Linux-aarch64"|"Linux-arm64") asset="pnpm-11.25.0-linux-arm64.tar.gz"; expected="6d62b433b7a77b77e814dfaca8032bae57bb79c1a5ad50442e688c4f7fed3c8a";; \
		"Linux-x86_64-musl") asset="pnpm-11.25.0-linux-x64-musl.tar.gz"; expected="2a25fd5614c89d3e8e7c8cabfe9f5f2aba3c4f997fb69e6934ee257dd8753ca5";; \
		"Darwin-arm64"|"Darwin-aarch64") asset="pnpm-11.25.0-darwin-arm64.tar.gz"; expected="cdcf7130ed2e7aa324c7c76ab597de66db0529b6b1e0db9e489bde538fdc0d04";; \
		*) echo "Unsupported OS/arch or missing mapping: $host_os-$arch" >&2; exit 1;; \
		esac; \
	fi; \
	tmpdir=$(mktemp -d); url="https://github.com/pnpm/pnpm/releases/download/v11.25.0/$asset"; \
	echo "Downloading $url"; curl -fL "$url" -o "$tmpdir/archive.tar.gz"; \
	printf "%s  %s\n" "$expected" "$tmpdir/archive.tar.gz" > "$tmpdir/expected.sha"; \
	(sha256sum -c "$tmpdir/expected.sha" || shasum -a 256 -c "$tmpdir/expected.sha") || { echo "Checksum failed" >&2; exit 2; }; \
	tar -xzf "$tmpdir/archive.tar.gz" -C "$tmpdir"; \
	pnpm_bin=$(find "$tmpdir" -type f -name pnpm -perm -111 | head -n1 || true); \
	if [ -z "$pnpm_bin" ]; then echo "pnpm binary not found in archive" >&2; exit 3; fi; \
	mkdir -p tools/bin; cp "$pnpm_bin" tools/bin/pnpm; chmod +x tools/bin/pnpm; rm -rf "$tmpdir";

install-theme:
	set -euo pipefail; \
	git submodule update --init --recursive; \
	git -C themes/apollo fetch --quiet || true; \
	git -C themes/apollo checkout a4de2efcb2a49076022eb01744c37d3de6c05500; \
	git -C themes/apollo submodule update --init --recursive; \
	echo "themes/apollo pinned to commit a4de2efc"

install-tools: install-just install-pnpm install-theme

verify-tools:
	@echo "Installed tools:"; ls -la tools/bin || true

# One-off admin tasks
regen-index:
	set -a; [ -f .env ] && source .env; set +a
	# Rebuild search index (Zola + any client-side index builder)
	zola build --output-dir public
	# If a JS-based search index build step exists, run it here (e.g. node script)
	# node scripts/build-search-index.js || true
	@echo "Index regenerated into public/"

audit-deps:
	# Run package manager audits
	pnpm audit || true
	@echo "Audit completed"

# Format code with biome (JS/TS/JSON/TOML/CSS) and prettier (HTML templates)
format:
	set -a; [ -f .env ] && source .env; set +a
	@echo "Formatting code..."
	# Format with biome (JS, JSON, TOML)
	pnpm exec biome format --write . || true
	# Format HTML templates with prettier (if available)
	pnpm exec prettier --write "templates/**/*.html" "content/**/*.md" || true
	@echo "✓ Formatting complete"
