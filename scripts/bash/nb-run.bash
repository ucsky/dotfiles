#!/usr/bin/env bash
#
# Description:
#   Execute a Jupyter notebook in batch mode and export an HTML report.
#
# Usage:
#   nb-run <path/to/notebook.ipynb>
#
set -euo pipefail

helpme() {
  echo ""
  echo "Run a Jupyter notebook in batch and output results as HTML."
  echo "Uses papermill if available, otherwise falls back to jupyter nbconvert."
  echo ""
  echo "See also: nb-pdf, nb-start."
  echo ""
}

if [ -z "${1:-}" ] || [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  if [ -z "${1:-}" ]; then
    echo "ERROR: please provide path to a Jupyter notebook." 1>&2
  fi
  helpme
  [ -z "${1:-}" ] && exit 1 || exit 0
fi

nb_in="$1"
nb_out="${nb_in%.ipynb}.out.ipynb"

export NOTEBOOK_BATCH=1

if command -v papermill >/dev/null 2>&1; then
  papermill --version
  papermill --request-save-on-cell-execute --log-output --report-mode --progress-bar "$nb_in" "$nb_out"
else
  jupyter nbconvert --version
  jupyter nbconvert --to notebook --execute "$nb_in" --output "$nb_out"
fi

jupyter nbconvert --to html "$nb_out"

