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
make setup
```

### Uninstall (safe)

```bash
./make/uninstall.bash
```

## Structure

- **`configs/`**: shell + editor configuration files.
- **`scripts/`**: command-line utilities (prefixed with `d51_`).
- **`make/`**: install helpers (including bare installers).
- **`tests/`**: test suite runnable via `make tests`.

## Development

### Python environment (venv / virtualenvwrapper / conda)

- **venv**: `make setup-venv`
- **virtualenvwrapper**: `make setup-workon` (env name: `dotfiles51`)
- **conda**: `make setup-miniconda` (env name: `dotfiles51`)

### Run tests

```bash
make tests
```

## See also

https://github.com/webpro/awesome-dotfiles


![linux icon](./assets/icon-tux.png)
