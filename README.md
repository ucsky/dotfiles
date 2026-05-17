# dotfiles

<p align="center">Keep it simple</p>

<p align="center">
  <a href="https://github.com/ucsky/dotfiles/actions/workflows/ci.yml"><img src="https://github.com/ucsky/dotfiles/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="https://github.com/ucsky/dotfiles/actions/workflows/security.yml"><img src="https://github.com/ucsky/dotfiles/actions/workflows/security.yml/badge.svg" alt="Security"></a>
</p>

## Install

```bash
cd $HOME
git clone git@github.com:ucsky/dotfiles.git .dotfiles
cd .dotfiles
./make/install.bash
```

You can clone the repo under **any name** — the Python virtual environments will be named after the directory (stripping the leading `.` if present):

```bash
cd $HOME
git clone git@github.com:ucsky/dotfiles.git .dotfiles34
cd .dotfiles34
./make/install.bash
# → venv created at ~/.venv/dotfiles34
```

Override the name explicitly with `NAME_PYTHON_VENV`:

```bash
NAME_PYTHON_VENV=myenv ./make/install.bash
```

### Alternative install (Makefile)

```bash
make install
```

### Uninstall (safe)

```bash
./make/uninstall.bash
```

## What's inside

### Shell configs (`configs/`)

| File | What it does |
|---|---|
| `bash/rc` | Prompt with git branch, fzf history search (Ctrl+R), git aliases (`gs`, `gl`, `gd`…), `autoload_dotenv`, `pathadd`, `wk` |
| `bash/profile` | Adds `scripts/bash`, `scripts/sh`, `scripts/python3` to `$PATH` |
| `zsh/rc` | Same PATH setup for zsh |
| `git/gitconfig` | Git aliases and sensible defaults |
| `vscode/` | VS Code settings |
| `emacs/` | Emacs init |

Notable shell features:
- **50 000-line history** shared across all terminals in real time
- **`autoload_dotenv`** — auto-sources `.env` files (owner-only, rejects world-writable files)
- **`fzf` integration** — fuzzy history search if fzf is installed

### Scripts (`scripts/`)

#### Bash (`scripts/bash/`)

| Script | Description |
|---|---|
| `7zmax.bash` | Compress a file or directory with maximum 7z compression |
| `docker-checksize.bash` | List disk usage of `/var/lib/docker` items |
| `docker-stop.bash` | Kill all running Docker containers |
| `git-add-extended.bash` | `git add` that clears Jupyter notebook outputs before staging |
| `git-export-all-file-versions.bash` | Export every historical version of a file from git |
| `git-lfs-diff.bash` | Diff a Git LFS-tracked file against HEAD |
| `mp4-to-mp3.bash` | Convert MP4 to MP3 via ffmpeg |
| `mset-get-info.bash` | Collect machine info into `~/.info/` |
| `nb-pdf.bash` | Convert a Jupyter notebook to PDF (code cells hidden by default) |
| `nb-run.bash` | Execute a notebook in batch mode and export an HTML report |
| `nb-start.bash` | Start Jupyter Notebook |
| `pip-fix-pip.bash` | Fix pip inside a virtualenv |
| `subsr.bash` | Bulk find-and-replace a string across files in a directory |
| `youtube-dl-audio.bash` | Download audio from a URL and convert to MP3 |

#### Python (`scripts/python3/`)

| Script | Description |
|---|---|
| `csv2yaml.py` | Convert CSV to YAML |
| `json2csv.py` | Convert JSON to CSV (via pandas) |
| `nb-check-params.py` | Check that Jupyter notebooks have a `parameters`-tagged cell |
| `nb-start.py` | Start Jupyter Notebook with sensible defaults |
| `papermill2csv` | Parse papermill progress logs into CSV |
| `parse-script-header.py` | Extract the `Description` block from a script header |

#### POSIX sh (`scripts/sh/`)

| Script | Description |
|---|---|
| `gcc-set-alternative` | Select a GCC/G++ version via `update-alternatives` |

### Docker (`docker/`)

Dockerfiles for testing the install on clean systems:

| Image | Base |
|---|---|
| `ubuntu/` | `ubuntu:24.04` — runs `make install && make tests` |
| `macos/` | macOS base |
| `mswin/` | Windows base |

Useful to verify the install is truly portable before pushing changes.

## Structure

```
.
├── configs/        # Shell + editor configuration files
│   ├── bash/
│   ├── zsh/
│   ├── git/
│   ├── emacs/
│   └── vscode/
├── docker/         # Dockerfiles for cross-platform install testing
│   ├── macos/
│   ├── mswin/
│   └── ubuntu/
├── hooks/          # Git hooks (e.g. notebook pre-commit cleaner)
├── make/           # Install / uninstall helpers
├── notebooks/      # Example Jupyter notebooks
├── scripts/        # Command-line utilities (bash, python3, sh)
└── tests/          # Test suite
```

## Development

### Python environments (venv / virtualenvwrapper / conda)

`./make/install.bash` (or `make install`) bootstraps Python tooling **idempotently**:

- **venv**: `~/.venv/<dirname>` (e.g. `~/.venv/dotfiles` when cloned as `.dotfiles`)
- **virtualenvwrapper**: env `<dirname>` under `~/.virtualenvs` (skipped if not installed)
- **conda**: env `<dirname>` (skipped if not installed)

The env name defaults to the cloned directory name (leading `.` stripped). Override with `NAME_PYTHON_VENV`.

### Start JupyterLab

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
