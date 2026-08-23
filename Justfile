# Justfile for Zola and Tailwind CSS blog

set shell := ["bash", "-c"]

# List all available recipes
default:
    @just --list

# Install all dependencies (mise and pnpm)
setup:
    mise install
    pnpm install

# Build Tailwind CSS for production (minified)
build-css:
    pnpm run build:css

# Watch and rebuild Tailwind CSS during development
watch-css:
    pnpm run watch:css

# Check the Zola site for errors
check:
    zola check

# Start the Zola local development server
serve:
    zola serve

# Build the site for production (builds CSS then builds Zola site)
build: build-css
    zola build

# Start development environment (runs Tailwind CSS watcher and Zola server concurrently)
[parallel]
blog: watch-css serve
