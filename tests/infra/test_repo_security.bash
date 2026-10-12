#!/usr/bin/env bash
#
# Repository security regression checks.
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if rg -n 'eval[[:space:]]+"\\$cmd"' "$REPO_ROOT/scripts/bash/mset-get-info.bash" >/dev/null 2>&1; then
  echo "ERROR: mset-get-info.bash must not use eval." 1>&2
  exit 1
fi

if rg -n 'export \$\(grep -v' "$REPO_ROOT/configs/bash/rc" >/dev/null 2>&1; then
  echo "ERROR: configs/bash/rc still uses unsafe dotenv loading." 1>&2
  exit 1
fi

if ! grep -F 'DOTFILES_INSTALL_MINICONDA:-0' "$REPO_ROOT/make/install_linux.bash" >/dev/null 2>&1; then
  echo "ERROR: Miniconda install must be opt-in." 1>&2
  exit 1
fi

if rg -n 'proceeding without verification' "$REPO_ROOT/make/install_linux.bash" >/dev/null 2>&1; then
  echo "ERROR: install_linux.bash must not run unverified installers." 1>&2
  exit 1
fi

if rg -n -v '^([A-Za-z0-9._-]+==[^#[:space:]]+)([[:space:]]+#.*)?$|^[[:space:]]*$' \
  "$REPO_ROOT/requirements.txt" >/dev/null 2>&1; then
  echo "ERROR: requirements.txt must contain only exact pins." 1>&2
  exit 1
fi

if rg -n 'HOME/micromamba\b' "$REPO_ROOT/Makefile" "$REPO_ROOT/make/install.bash" >/dev/null 2>&1; then
  echo "ERROR: micromamba defaults must use the dotted \$HOME/.micromamba, not \$HOME/micromamba." 1>&2
  exit 1
fi

for wf in "$REPO_ROOT"/.github/workflows/*.yml "$REPO_ROOT"/.github/workflows/*.yaml; do
  [ -e "$wf" ] || continue
  if ! grep -Eq '^permissions:' "$wf"; then
    echo "ERROR: $(basename "$wf") must declare top-level 'permissions:' (least privilege)." 1>&2
    exit 1
  fi
done

# Third-party actions must be pinned to a full commit SHA (tags are mutable).
# Local actions (./path) and docker:// references are exempt.
# The workflows are parsed as YAML so that any valid spelling of `uses`
# (quoted key, flow-style step, extra spaces) is covered.
if ! python3 -c 'import yaml' >/dev/null 2>&1; then
  echo "ERROR: PyYAML is required to check action pinning (pip install pyyaml)." 1>&2
  exit 1
fi
python3 - "$REPO_ROOT"/.github/workflows/*.yml "$REPO_ROOT"/.github/workflows/*.yaml <<'PY'
import os
import re
import sys

import yaml

PINNED = re.compile(r"^[^@\s]+@[0-9a-f]{40}$")
errors = []


def walk(node, path):
    if isinstance(node, dict):
        for key, value in node.items():
            if key == "uses" and isinstance(value, str):
                ref = value.strip()
                if not ref.startswith(("./", "docker://")) and not PINNED.match(ref):
                    errors.append(f"{path}: uses: {ref}")
            else:
                walk(value, path)
    elif isinstance(node, list):
        for item in node:
            walk(item, path)


for wf in sys.argv[1:]:
    if not os.path.exists(wf):
        continue
    with open(wf, encoding="utf-8") as fh:
        walk(yaml.safe_load(fh), os.path.basename(wf))

if errors:
    print("ERROR: actions not pinned to a full commit SHA:", file=sys.stderr)
    for err in errors:
        print(f"  {err}", file=sys.stderr)
    sys.exit(1)
PY

echo "Repository security checks passed."
