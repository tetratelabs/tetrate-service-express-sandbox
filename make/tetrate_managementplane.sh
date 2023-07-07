#!/usr/bin/env bash
set -e

export ROOT_DIR="$(
	cd -- "$(dirname "${0}")" >/dev/null 2>&1
	pwd -P
)"
source ${ROOT_DIR}/variables.sh


export ACTION=${1}

if [[ ${ACTION} = "deploy" ]]; then
	source ${ROOT_DIR}/k8s_auth.sh refresh
	cd "${ROOT_DIR}/../tetrate/tse_managementplane"
	export AWS_K8S_CLUSTERS=$(echo ${TFVARS} | jq -c ".k8s_clusters.aws")
	index=0 # Install MP on the first cluster from the list
	cluster_name=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].name')
	region=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].region')
		terraform workspace select default
		terraform init
		terraform apply ${TERRAFORM_APPLY_ARGS} -var-file="../../terraform.tfvars.json" -var=region=$region 
		terraform output ${TERRAFORM_OUTPUT_ARGS} | jq . >../../outputs/terraform_outputs/terraform-tse-managementplane.json
		terraform workspace select default
	cd "../.."
fi

