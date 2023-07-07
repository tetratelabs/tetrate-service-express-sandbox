#!/usr/bin/env bash -x
set -e

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
