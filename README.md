# My Blog

Deployed site: https://headless-voyager.vercel.app

This site is built with Zola using the apollo theme, alongside Tailwind CSS.

## Getting Started

This project uses [mise](https://mise.jdx.co/) for tool/dependency management and [just](https://github.com/casey/just) for running tasks.

To set up your environment and install all dependencies (including Zola, Tailwind CSS, and Node/pnpm package dependencies):

```shell
just setup
```

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
