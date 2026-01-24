#!/usr/bin/env python3
"""
Start Jupyter Notebook with sensible defaults.

This replaces older IPython-based launchers and delegates to the `jupyter` CLI.
"""

import os
import subprocess
import sys
from pathlib import Path


def main() -> int:
    notebook_dir = Path(os.environ.get("NOTEBOOK_DIR", str(Path.home() / "notebooks")))
    if not notebook_dir.exists():
        notebook_dir = Path.home()

    cmd = ["jupyter", "notebook", "--notebook-dir", str(notebook_dir)]
    cmd.extend(sys.argv[1:])

    try:
        return subprocess.call(cmd)
    except FileNotFoundError:
        print("ERROR: 'jupyter' not found. Install it first (see requirements.txt).", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())

