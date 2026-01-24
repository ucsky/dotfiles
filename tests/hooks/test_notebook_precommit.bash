#!/usr/bin/env bash
#
# Test the notebook pre-commit hook:
# - Create a temporary git repo
# - Add a notebook with outputs
# - Stage it
# - Run the hook
# - Verify outputs are cleared in the staged version
#
set -euo pipefail

if ! command -v jupyter >/dev/null 2>&1; then
  echo "Skipping: jupyter not installed."
  exit 0
fi

if ! python3 -c "import nbformat" >/dev/null 2>&1; then
  echo "Skipping: nbformat not installed."
  exit 0
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HOOK="$REPO_ROOT/hooks/notebook.pre-commit.bash"

tmpdir="$(mktemp -d)"
cleanup() { rm -rf "$tmpdir"; }
trap cleanup EXIT

cd "$tmpdir"
git init -q
git config user.email "test@example.com"
git config user.name "test"

python3 - <<'PY'
import nbformat
from nbformat.v4 import new_code_cell, new_notebook, new_output

nb = new_notebook(
    cells=[
        new_code_cell(
            source="print('hello')",
            outputs=[new_output("stream", name="stdout", text="hello\n")],
            execution_count=1,
        )
    ]
)
with open("a.ipynb", "w", encoding="utf-8") as f:
    nbformat.write(nb, f)
PY

git add a.ipynb

bash "$HOOK"

python3 - <<'PY'
import nbformat
nb = nbformat.read("a.ipynb", as_version=4)
assert nb.cells[0].outputs == [], "outputs were not cleared"
print("OK")
PY
