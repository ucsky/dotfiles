#!/usr/bin/env python3
"""
Extract the 'Description' block from a script header.

This is useful to generate documentation for scripts that use a header like:

  # Description: ...
  # Usage: ...
"""

import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 2:
        print(f"Usage: {Path(sys.argv[0]).name} <script-file>", file=sys.stderr)
        return 1

    path = Path(sys.argv[1])
    if not path.exists():
        print(f"ERROR: file not found: {path}", file=sys.stderr)
        return 1

    description_parts: list[str] = []
    found = False
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        if line.startswith("# Description:"):
            description_parts.append(line.replace("# Description:", "", 1).strip())
            found = True
            continue
        if found:
            if line.startswith("# Usage:"):
                break
            if line.startswith("#"):
                description_parts.append(line.lstrip("#").strip())
            else:
                break

    print(" ".join([p for p in description_parts if p]).strip())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
