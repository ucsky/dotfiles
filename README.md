# dotfiles 51
<p align="center">Keep it simple</p>

## Install

```bash
cd $HOME
git clone git@github.com:ucsky/dotfiles.git .dotfiles
cd .dotfiles
./make/install.bash
```

### Alternative install (Makefile)

```bash
make install
```

### Uninstall (safe)

```bash
./make/uninstall.bash
```

## Structure

- **`configs/`**: shell + editor configuration files.
- **`scripts/`**: command-line utilities.
- **`make/`**: install helpers (including bare installers).
- **`tests/`**: test suite runnable via `make tests`.

## Development

### Python environments (venv / virtualenvwrapper / conda)

`./make/install.bash` (or `make install`) bootstraps Python tooling **idempotently**:

- **venv**: `~/.venv/dotfiles51`
- **virtualenvwrapper**: env `dotfiles51` under `~/.virtualenvs` (skipped if virtualenvwrapper is not installed)
- **conda**: env `dotfiles51` (skipped if conda is not installed)

You can override the environment name via `NAME_PYTHON_VENV` (default: `dotfiles51`).

### Start JupyterLab

Use `DOTFILES_PY_ENV` to select the Python environment type:

```bash
DOTFILES_PY_ENV=venv  make startlab
DOTFILES_PY_ENV=workon make startlab
DOTFILES_PY_ENV=conda make startlab
```

### Run tests

```bash
make tests
```

## See also

[awesome-dotfiles](https://github.com/webpro/awesome-dotfiles)


![linux icon](./assets/icon-tux.png)
