#!/usr/bin/env bash
#
# Description:
#   Convert a Jupyter notebook to PDF while hiding code cells by default.
#
# Usage:
#   d51_jpdf <path/to/notebook.ipynb>
#
set -euo pipefail

helpme() {
  echo ""
  echo "Convert a Jupyter notebook to PDF without code."
  echo ""
  echo "See also: d51_jrun, d51_jstart."
  echo ""
}

if [ -z "${1:-}" ] || [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  if [ -z "${1:-}" ]; then
    echo "ERROR: please provide path to a Jupyter notebook." 1>&2
  fi
  helpme
  [ -z "${1:-}" ] && exit 1 || exit 0
fi

nb_path="$1"
jupy="$(basename "$nb_path")"
dir="$(dirname "$nb_path")"

pushd "$dir" >/dev/null

cat > hidecode.tplx <<'EOF'
((*- extends 'article.tplx' -*))
((* block input_group *))
    ((*- if cell.metadata.get('nbconvert', {}).get('show_code', False) -*))
         ((( super() )))
    ((*- endif -*))
((* endblock input_group *))
EOF

jupyter nbconvert --to pdf --template hidecode "$jupy"
rm -f hidecode.tplx
popd >/dev/null
