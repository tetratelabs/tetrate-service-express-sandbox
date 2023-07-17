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

export OUTPUTS_DIR=${ROOT_DIR}/../outputs

export TERRAFORM_APPLY_ARGS="-compact-warnings -auto-approve"
export TERRAFORM_DESTROY_ARGS="-compact-warnings -auto-approve"
export TERRAFORM_WORKSPACE_ARGS="-force"
export TERRAFORM_OUTPUT_ARGS="-json"

export TFVARS_LOCATION="${ROOT_DIR}/../terraform.tfvars.json"
export TFVARS=$(jq -c . ${TFVARS_LOCATION})

export NAME_PREFIX=$(echo ${TFVARS} | jq -r ".name_prefix")

export GIT_REPO=$(echo ${TFVARS} | jq -r ".git_repo")

if [ "${GIT_REPO}" = "null" ]; then
    export GIT_REPO="https://github.com/smarunich/tetrate-service-express-sandbox"
fi

run_command_at_jumpbox() {
  local cluster_index="$1"
  local input="$*"
  local command=("${input[@]:1}")
  export helper_script=${OUTPUTS_DIR}/ssh-to-aws-${NAME_PREFIX}-$cluster_index-jumpbox.sh
  
  (    
    print_command ${command}
    cd ${OUTPUTS_DIR} && ${helper_script} ${command}
  )
}

# Print info messages
function print_info {
  echo -e "${bgreen}${*}"
}

# Print warning messages
function print_warning {
  echo -e "${byellow}${*}"
}

# Print error messages
function print_error {
  echo -e "${bred}${*}"
}

# Print command messages
function print_command {
  echo -e "${bblue}${*}"
}