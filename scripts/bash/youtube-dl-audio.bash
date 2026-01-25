#!/usr/bin/env bash
#
# Description:
#   Download audio from a URL and convert it to MP3 using youtube-dl.
#
# Usage:
#   youtube-dl-audio <url>
#
set -euo pipefail

url="${1:-}"
if [ -z "$url" ]; then
  echo "ERROR: please provide a URL." 1>&2
  exit 1
fi

if [ -f "${WORKON_HOME:-}/youtube-dl/bin/activate" ]; then
  # shellcheck disable=SC1090
  source "${WORKON_HOME}/youtube-dl/bin/activate"
fi

youtube-dl --extract-audio --audio-format mp3 "$url"
