#!/usr/bin/env bash
#
# Description:
#   Compress a file or directory as a `.7z` archive using maximum compression.
#
# Usage:
#   7zmax <file_or_folder_to_compress>
#
set -euo pipefail

if [ "${1:-}" = "" ]; then
  echo "Usage: $(basename "$0") <file_or_folder_to_compress>" 1>&2
  exit 1
fi

input_path="$1"
output_path="${input_path}.7z"

7z a -t7z -m0=lzma2 -mx=9 -ms=on "$output_path" "$input_path"
echo "Compression successful: $output_path"
