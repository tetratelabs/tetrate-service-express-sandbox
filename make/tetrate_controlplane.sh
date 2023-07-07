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
	cd "${ROOT_DIR}/../tetrate/tse_controlplane"
	export AWS_K8S_CLUSTERS=$(echo ${TFVARS} | jq -c ".k8s_clusters.aws")
	export AWS_K8S_CLUSTERS_COUNT=$(echo ${AWS_K8S_CLUSTERS} | jq length)
	for i in $(seq 1 ${AWS_K8S_CLUSTERS_COUNT}); do
		index=$(($i - 1))
		cluster_name=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].name')
		region=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].region')
		k8s_version=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].version')
		terraform workspace new aws-$index-$region || true
		terraform workspace select aws-$index-$region
		terraform init
		terraform apply ${TERRAFORM_APPLY_ARGS} -var-file="../../terraform.tfvars.json" \
			-var=cluster_name=$cluster_name -var=cluster_id=$index -var=region=$region
		terraform output ${TERRAFORM_OUTPUT_ARGS} | jq . >../../outputs/terraform_outputs/terraform-aws-$index-$cluster_name.json
		terraform workspace select default
	done
	cd "../.."
fi