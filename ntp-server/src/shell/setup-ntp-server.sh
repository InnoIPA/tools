#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

version="1.0.0"
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
${BASH_SOURCE[0]} ${version}
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-s] [--config-server arg1 [arg2...]]
Example: ./setup-ntp-server.sh -s --config-server "server 0.asia.pool.ntp.org" "server 1.asia.pool.ntp.org"

The script will install the NTP service and can specify one or more NTP servers.
If no NTP server is specified, the default will be used.

Available options:

-h, --help        Print this help and exit
-v, --verbose     Print script debug info
-s, --status      Print NTP service status
--config-server   Configure NTP server
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  show_ntp_status=0
  config=0

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -s | --status) show_ntp_status=1 ;;
    --config-server)
      config=1
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  if [ ${config} == 1 ]
  then
    [[ ${#args[@]} -eq 0 ]] && die "${ORANGE}Missing --config-server arguments${NOFORMAT}"
  fi

  return 0
}

install_ntp_service()
{
  sudo apt-get install -y ntp
}

config_ntp_server()
{
  file=/etc/ntp.conf
  file_backup=/etc/ntp_backup.conf

  if [ -f "${file_backup}" ]; then
    sudo cp "${file_backup}" "${file}"
  else 
    sudo cp "${file}" "${file_backup}"
  fi

  cmd="/# more information./a "
  for ELEMENT in "${args[@]-}"; do
    cmd+="${ELEMENT}\n"
  done
  
  sudo sed -i '/pool/d' "${file}"
  sudo sed -i "${cmd}" "${file}"
}

restart_ntp_service()
{
  sudo systemctl restart ntp
}

check_ntp_status()
{
  sudo systemctl status ntp
}

ufw_allow()
{
  sudo ufw allow from any to any port 123 proto udp
}

setup_colors
parse_params "$@"

# script logic here
install_ntp_service

if [ $config == 1 ]
then
  config_ntp_server
  restart_ntp_service
fi

ufw_allow

if [ $show_ntp_status == 1 ]
then
  check_ntp_status
fi