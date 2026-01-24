#!/usr/bin/env python3
"""
Convert a JSON file into a CSV file using pandas.
"""

import sys
from pathlib import Path

import pandas as pd


def main() -> int:
    if len(sys.argv) != 2:
        print(f"Usage: {Path(sys.argv[0]).name} <file.json>", file=sys.stderr)
        return 1

    pin = Path(sys.argv[1])
    if not pin.exists():
        print(f"ERROR: file not found: {pin}", file=sys.stderr)
        return 1

    pout = pin.with_suffix(".csv")
    df = pd.read_json(pin)
    df.to_csv(pout, index=False)
    print(f"Wrote: {pout}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
