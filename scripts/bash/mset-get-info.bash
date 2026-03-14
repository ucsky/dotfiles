#!/usr/bin/env bash
#
# Description:
#   Collect useful information about a Linux machine into a directory (default: $HOME/.info).
#
# Usage:
#   mset-get-info.bash [-p <path> | --path <path>] [-h | --help]
#
set -euo pipefail

PATH_INFO="$HOME/.info"

check_sudo() {
  if [ "$(id -u)" -eq 0 ]; then
    return 0
  fi

  sudo -n true >/dev/null 2>&1
}

HAS_SUDO=0
if check_sudo; then
  HAS_SUDO=1
fi

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
  local filename="$1"
  shift
  echo "Executing: $*"
  "$@" > "$PATH_INFO/$filename.txt"
}

exec_with_sudo_and_save() {
  local filename="$1"
  shift

  if [ "$HAS_SUDO" -eq 0 ]; then
    echo "WARNING: sudo required but not available. Skipping: $*" 1>&2
    return 0
  fi

  if [ "$(id -u)" -eq 0 ]; then
    exec_and_save "$filename" "$@"
  else
    echo "Executing: sudo -n $*"
    sudo -n "$@" > "$PATH_INFO/$filename.txt"
  fi
}

save_df_summary() {
  echo "Executing: df summary"
  df -h | awk '{print $1, $2, $NF}' | sed "s/Size on/Size On/" > "$PATH_INFO/df.2.txt"
}

save_free_summary() {
  echo "Executing: free summary"
  free -m | awk '{print $2}' | sed -e 's/used/Total/' > "$PATH_INFO/free.2.txt"
}

exec_and_save "lsb_release" lsb_release -a
exec_and_save "hostnamectl" hostnamectl
exec_and_save "uname" uname -a
exec_and_save "df" df -h
save_df_summary
exec_and_save "free" free -m
save_free_summary
exec_and_save "lscpu" lscpu
exec_with_sudo_and_save "lshw" lshw
exec_and_save "lsblk" lsblk
exec_with_sudo_and_save "dmidecode" dmidecode
exec_and_save "ip_a" ip a
exec_and_save "ss" ss -tuln

if command -v inxi >/dev/null 2>&1; then
  exec_and_save "inxi" inxi -Fxz
fi

echo "All information has been collected in $PATH_INFO."
