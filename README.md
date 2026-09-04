# My Blog

Deployed site: https://headless-voyager.vercel.app

This site is built with Zola using the apollo theme, alongside Tailwind CSS.

## Getting Started

This project uses [mise](https://mise.jdx.co/) for tool/dependency management and [just](https://github.com/casey/just) for running tasks.

Top-level tasks from the Justfile are also mirrored in mise.toml under the [tasks] table so external tooling can discover them. To set up your environment and install all dependencies (including Zola, Tailwind CSS, and Node/pnpm package dependencies):

```shell
# ensure tools are available
mise install
# then run the setup task (installs node modules)
just setup
```

You can copy .env.example -> .env to override build-time config loaded by the Justfile (.env usage documented in mise.toml).
## Local Development

To start both the Tailwind CSS compiler (watching for changes) and the Zola local server concurrently, run:

```shell
just blog
```

The site will be available at http://127.0.0.1:1111.

## Production Build

To compile the Tailwind CSS assets for production and build the final static site:

```shell
just build
```

## All Commands

Run `just` without any arguments to see a full list of available recipes:

```shell
just
```

CI: A GitHub Actions workflow is included at .github/workflows/ci.yml that
performs digest-verified tool installs, caches pnpm and tools, runs checks,
and uploads the built site (public/) as an artifact. Add SITE_BASE_URL and
other secrets in the repository settings if you want CI to use them.
