# Agent instructions (AI IDE)

This repository is a personal `dotfiles` and utilities collection.

## Language

- All documentation and code comments must be written in **English**.

## Repository conventions

- Shell scripts use **bash** unless explicitly marked otherwise.
- Utilities are stored in `scripts/` and are meant to be runnable from the command line.
- Configuration files are stored in `configs/`.
- Tests live in `tests/` and should be runnable via `make tests`.
- `make/install.bash` is a non-interactive installer and must stay **idempotent**.

## Safety rules

- Avoid destructive operations by default (deleting user data, wiping Docker, etc.).
- If an uninstall script is provided, keep it **safe** and **idempotent**.
- If admin/sudo is not available, installers must **not fail**; print an info message and continue with non-privileged steps.

## What to keep consistent

- `make install` (or `./make/install.bash`) should remain the main entry point.
- CI must run the real tests (no placeholder `echo`).
- Python environments are bootstrapped during install (venv + virtualenvwrapper + conda when available).
