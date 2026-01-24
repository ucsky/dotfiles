#!/usr/bin/env bash
#
# Description:
#   Collect useful information about a Linux machine into a directory (default: $HOME/.info).
#
# Usage:
#   d51_mset-get-info.bash [-p <path> | --path <path>] [-h | --help]
#
set -euo pipefail

PATH_INFO="$HOME/.info"

check_sudo() {
  if [ "$(whoami)" = "root" ]; then
    echo "1"
  else
    groups "$(whoami)" | grep -E '\ssudo(\s|$)' >/dev/null 2>&1 && echo "1" || echo "0"
  fi
}

HAS_SUDO="$(check_sudo)"

while true; do
  case "${1:-}" in
    -p|--path)
      PATH_INFO="${2:-}"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $(basename "$0") [-p <path> | --path <path>] [-h | --help]"
      echo "  -p, --path : Custom output directory."
      echo "  -h, --help : Show this help."
      exit 0
      ;;
    --)
      shift
      break
      ;;
    "")
      break
      ;;
    *)
      echo "Invalid option: $1" 1>&2
      exit 1
      ;;
  esac
done

mkdir -p "$PATH_INFO"

exec_and_save() {
  local cmd="$1"
  local filename="$2"
  echo "Executing: $cmd"
  if [[ "$cmd" == sudo* && "$HAS_SUDO" -eq 0 ]]; then
    echo "WARNING: sudo required but not available. Skipping: $cmd" 1>&2
    return 0
  fi
  # shellcheck disable=SC2086
  eval "$cmd" > "$PATH_INFO/$filename.txt"
}

exec_and_save "lsb_release -a" "lsb_release"
exec_and_save "hostnamectl" "hostnamectl"
exec_and_save "uname -a" "uname"
exec_and_save "df -h" "df"
exec_and_save "df -h | awk '{print \\$1, \\$2, \\$NF}' | sed s'/Size on/Size On/'" "df.2"
exec_and_save "free -m" "free"
exec_and_save "free -m | awk '{print \\$2}' | sed -s 's/used/Total/'" "free.2"
exec_and_save "lscpu" "lscpu"
exec_and_save "sudo lshw" "lshw"
exec_and_save "lsblk" "lsblk"
exec_and_save "sudo dmidecode" "dmidecode"
exec_and_save "ip a" "ip_a"
exec_and_save "ss -tuln" "ss"

if command -v inxi >/dev/null 2>&1; then
  exec_and_save "inxi -Fxz" "inxi"
fi

echo "All information has been collected in $PATH_INFO."
