#!/bin/bash
#
# Description: Recover information of a linux machine.
#              
# Tags: mset, linux
#
##

# Initialization of variables
PATH_INFO="$HOME/.info" # Default path to store information

# Function to check if the user has sudo privileges
check_sudo() {
    # Check if user has sudo
    if [ "`whoami`" == root ];then
    echo "1"
    else
    groups `whoami` | egrep '\ssudo\s' >> /dev/null && echo "1" || echo "0"
    fi
}

HAS_SUDO=$(check_sudo)

# Handling arguments
while true; do
  case "$1" in
    -p | --path )
      PATH_INFO="$2"
      shift 2
      ;;
    -h | --help )
      echo "Usage: $0 [-p <path> | --path <path>] [-h | --help]"
      echo "    -p, --path : Specify the custom path where to store the information."
      echo "    -h, --help : Displays this help message."
      exit 0
      ;;
    -- )
      shift
      break
      ;;
    * )
      if [ "$#" -eq 0 ]; then break; else echo "Invalid option: $1" 1>&2; exit 1; fi
      ;;
  esac
done

# Create the directory if it does not exist
mkdir -p "$PATH_INFO"

# Function to execute and save information from a command
exec_and_save() {
  local cmd=$1
  local filename=$2
  echo "Executing $cmd..."
  if [[ $cmd == sudo* && $HAS_SUDO -eq 0 ]]; then
    echo "Warning: sudo privileges required but not available. Skipping command $cmd."
    return
  fi
  eval "$cmd" > "$PATH_INFO/$filename.txt"
}

# Commands to collect information
exec_and_save "lsb_release -a" "lsb_release"
exec_and_save "hostnamectl" "hostnamectl"
exec_and_save "uname -a" "uname"
exec_and_save "df -h" "df"
exec_and_save "df -h | awk '{print \$1, \$2, \$NF}' | sed s'/Size on/Size On/'" "df.2"
exec_and_save "free -m" "free"
exec_and_save "free -m | awk '{print \$2}' | sed -s 's/used/Total/'" "free.2"
exec_and_save "lscpu" "lscpu"
exec_and_save "sudo lshw" "lshw"
exec_and_save "lsblk" "lsblk"
exec_and_save "sudo dmidecode" "dmidecode"
exec_and_save "ip a" "ip_a"
exec_and_save "ss -tuln" "ss"

# Check if `inxi` is installed and execute it if present
if command -v inxi &> /dev/null; then
  exec_and_save "inxi -Fxz" "inxi"
fi

echo "All information has been collected in $PATH_INFO."
