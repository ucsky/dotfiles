# Agent instructions (AI IDE)

This repository is a personal `dotfiles` and utilities collection.

## Language

- All documentation and code comments must be written in **English**.

## Repository conventions

- Shell scripts use **bash** unless explicitly marked otherwise.
- Utilities are stored in `scripts/` and are meant to be runnable from the command line.
- Configuration files are stored in `configs/`.
- Tests live in `tests/` and should be runnable via `make tests`.

## Safety rules

- Avoid destructive operations by default (deleting user data, wiping Docker, etc.).
- If an uninstall script is provided, keep it **safe** and **idempotent**.

## What to keep consistent

- `make setup` (or `./make/install.bash`) should remain the main entry point.
- CI must run the real tests (no placeholder `echo`).
