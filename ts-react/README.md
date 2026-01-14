# React + TypeScript + Vite Template

A minimal React template with TypeScript, Vite, and Nix development environment.

## Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- [direnv](https://direnv.net/) (optional but recommended)

## Getting Started

### 1. Enter the development environment

With direnv (automatic):
```bash
direnv allow
```

Without direnv (manual):
```bash
nix develop
```

This will set up Node.js, pnpm, and all necessary development tools automatically.

## Available Commands

| Command | Description |
|---------|-------------|
| `pnpm install` | Install dependencies |
| `pnpm dev` | Start development server with hot reload |
| `pnpm build` | Build optimized production bundle |
| `pnpm preview` | Preview production build locally |
| `pnpm lint` | Lint code with ESLint |
| `treefmt` | Format all files (Nix, TypeScript, CSS, etc.) |
| `nix fmt` | Format files using flake formatter |

## Formatting

This project uses `treefmt` to automatically format code:

- **Alejandra** - Nix files
- **Prettier** - TypeScript, JavaScript, CSS, HTML, JSON, Markdown
- **ESLint** - Linting and auto-fixing for TypeScript/JavaScript

Run `treefmt` to format all files, or `nix fmt` to use the flake formatter.
