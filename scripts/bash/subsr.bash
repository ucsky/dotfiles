#!/usr/bin/env bash
#
# Description:
#   Substitute a string ($1) by another string ($2) in files under a directory ($3).
#
# Usage:
#   subsr <old> <new> <directory>
#
# Notes:
#   This script is interactive and will ask for confirmation.
#
set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "Usage: $(basename "$0") <old> <new> <directory>" 1>&2
  exit 0
fi

old_str="$1"
new_str="$2"
dir="$3"

echo ""
echo "You are going to substitute:"
echo "  $old_str"
echo "by:"
echo "  $new_str"
echo "in directory:"
echo "  $dir"
echo ""
read -r -p "Is that correct? (yes/no) " answer

if [ "$answer" != "yes" ]; then
  echo "Aborted."
  exit 1
fi

backup_root="${old:-/tmp}"
backup_dir="$backup_root/subsr"
mkdir -p "$backup_dir"

# -l lists each matching file once; a duplicated list would make the loop
# below run sed several times on the same file, which compounds when
# new_str contains old_str (e.g. foo -> prefix_foo -> prefix_prefix_foo).
files="$(grep -rl --exclude-dir=.svn --exclude-dir=.git -- "$old_str" "$dir" || true)"

for f in $files; do
  cp -f "$f" "$backup_dir"
done
echo "Backups saved to $backup_dir"

for f in $files; do
  echo "Substituting in $f"
  sed "s#${old_str}#${new_str}#g" "$f" > "${f}.tmp"
  mv "${f}.tmp" "$f"
done
