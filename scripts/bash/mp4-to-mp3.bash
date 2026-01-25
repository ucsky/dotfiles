#!/usr/bin/env bash
#
# Description:
#   Convert an MP4 file to MP3 using ffmpeg.
#
# Usage:
#   mp4-to-mp3.bash <file.mp4>
#
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: $(basename "$0") <file.mp4>" 1>&2
  exit 1
fi

in="$1"
out="${in%.mp4}.mp3"

ffmpeg -i "$in" -vn -acodec libmp3lame -ac 2 -qscale:a 4 -ar 48000 "$out"
