#!/usr/bin/env bash
set -e

# colors
# bold
bblack="\033[1;30m"       # black
bred="\033[1;31m"         # red
bgreen="\033[1;32m"       # green
byellow="\033[1;33m"      # yellow
bblue="\033[1;34m"        # blue
bpurple="\033[1;35m"      # purple
bcyan="\033[1;36m"        # cyan
bwhite="\033[1;37m"       # white
# underline
ublack="\033[4;30m"       # black
ured="\033[4;31m"         # red
ugreen="\033[4;32m"       # green
uyellow="\033[4;33m"      # yellow
ublue="\033[4;34m"        # blue
upurple="\033[4;35m"      # purple
ucyan="\033[4;36m"        # cyan
uwhite="\033[4;37m"       # white
end="\033[0m"

export ROOT_DIR="$(
  cd -- "$(dirname "${0}")" >/dev/null 2>&1
  pwd -P
)"

export TERRAFORM_APPLY_ARGS="-compact-warnings -auto-approve"
export TERRAFORM_DESTROY_ARGS="-compact-warnings -auto-approve"
export TERRAFORM_WORKSPACE_ARGS="-force"
export TERRAFORM_OUTPUT_ARGS="-json"

export TFVARS_LOCATION="${ROOT_DIR}/../terraform.tfvars.json"
export TFVARS=$(jq -c . ${TFVARS_LOCATION})

export NAME_PREFIX=$(echo ${TFVARS} | jq -r ".name_prefix")

# Print info messages
function print_info {
  echo -e "${greenb}${1}${end}"
}

# Print warning messages
function print_warning {
  echo -e "${yellowb}${1}${end}"
}

# Print error messages
function print_error {
  echo -e "${redb}${1}${end}"
}

# Print command messages
function print_command {
  echo -e "${lightblueb}${1}${end}"
}