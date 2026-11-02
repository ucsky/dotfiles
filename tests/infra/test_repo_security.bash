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

if rg -n -v '^([A-Za-z0-9._-]+==[^#[:space:]]+)([[:space:]]+#.*)?$|^[[:space:]]*(#.*)?$' \
  "$REPO_ROOT/requirements.in" >/dev/null 2>&1; then
  echo "ERROR: requirements.in must contain only exact pins." 1>&2
  exit 1
fi

# The installers must only install the hash-locked requirements file:
# every `pip install -r` in make/ goes through --require-hashes, and no
# hand-rolled download (urllib/urlretrieve) of Python packages is allowed.
if rg -n 'pip install[^\n]*-r ' "$REPO_ROOT/make" | rg -v -- '--require-hashes' >/dev/null 2>&1; then
  echo "ERROR: make/ must install requirements with --require-hashes." 1>&2
  rg -n 'pip install[^\n]*-r ' "$REPO_ROOT/make" | rg -v -- '--require-hashes' 1>&2
  exit 1
fi
if rg -n 'urlretrieve|urllib\.request' "$REPO_ROOT/make" >/dev/null 2>&1; then
  echo "ERROR: make/ must not download Python packages outside pip's hash checking." 1>&2
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

# Python packages installed by workflows must be locked with hashes:
# every `pip install` in a `run:` step must use `--require-hashes -r <file>`,
# and the CI lock file must carry a hash for every pinned package.
python3 - "$REPO_ROOT" "$REPO_ROOT"/.github/workflows/*.yml "$REPO_ROOT"/.github/workflows/*.yaml <<'PY'
import os
import re
import sys

import yaml

repo_root, workflows = sys.argv[1], sys.argv[2:]
errors = []
PIP_INSTALL = re.compile(r"\bpip3?\s+install\b")


def walk(node, path):
    if isinstance(node, dict):
        for key, value in node.items():
            if key == "run" and isinstance(value, str):
                script = value.replace("\\\n", " ")
                for line in script.splitlines():
                    if PIP_INSTALL.search(line) and not (
                        "--require-hashes" in line and re.search(r"\s-r\s", line)
                    ):
                        errors.append(f"{path}: {line.strip()}")
            else:
                walk(value, path)
    elif isinstance(node, list):
        for item in node:
            walk(item, path)


for wf in workflows:
    if not os.path.exists(wf):
        continue
    with open(wf, encoding="utf-8") as fh:
        walk(yaml.safe_load(fh), os.path.basename(wf))

# Both lock files (CI tooling and the user environments) must pin every
# package, transitive ones included, with at least one sha256 hash.
# An optional environment marker (`; sys_platform == 'darwin'`) is allowed.
LOCKED = re.compile(
    r"^[A-Za-z0-9._-]+==[^\s;]+(\s*;[^-]+?)?(\s+--hash=sha256:[0-9a-f]{64})+$"
)
for rel in (os.path.join(".github", "requirements-ci.txt"), "requirements.txt"):
    lock = os.path.join(repo_root, rel)
    if not os.path.exists(lock):
        errors.append(f"{rel} is missing")
        continue
    with open(lock, encoding="utf-8") as fh:
        content = fh.read().replace("\\\n", " ")
    for line in content.splitlines():
        line = line.split("#", 1)[0].strip()
        if not line:
            continue
        if not LOCKED.match(line):
            errors.append(f"{rel}: not pinned with a hash: {line.split()[0]}")

if errors:
    print("ERROR: Python dependencies must be hash-locked:", file=sys.stderr)
    for err in errors:
        print(f"  {err}", file=sys.stderr)
    sys.exit(1)
PY

echo "Repository security checks passed."
