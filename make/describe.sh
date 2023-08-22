#!/usr/bin/env bash
set -e

export ROOT_DIR="$(
	cd -- "$(dirname "${0}")" >/dev/null 2>&1
	pwd -P
)"
source ${ROOT_DIR}/variables.sh

export ACTION=${1}

if [[ ${ACTION} = "demo" ]]; then
	TSE_MANAGEMENTPLANE=$(cat ${ROOT_DIR}/../outputs/terraform_outputs/terraform-tse-managementplane.json | jq .tetrate_managementplane_hostname.value)
	TSE_USERNAME=$(cat ${ROOT_DIR}/../outputs/terraform_outputs/terraform-tse-managementplane.json | jq .tetrate_managementplane_username.value)
	TSE_PASSWORD=$(cat ${ROOT_DIR}/../outputs/terraform_outputs/terraform-tse-managementplane.json | jq .tetrate_managementplane_password.value)
	print_info "${bblue}Welcome to Tetrate Service Express Demo Environment on AWS Elastic Kubernetes Service using Terraform"
	echo -e "${bgreen}- Tetrate Service Express Management Plane is reachable at ${bblue}https://$TSE_MANAGEMENTPLANE ${bgreen}with username username: ${bblue}$TSE_USERNAME ${bgreen}and password:${bblue} $TSE_PASSWORD" | tr -d '"'
	echo -e "${bgreen}- Please consult KB for tctl access: ${ublue}https://docs-preview.tetrate.io/service-express/Tech-Preview/installation/management-plane#access-the-management-plane-using-a-web-browser${end}"
	echo -e "${bgreen}- tctl access is also provided using ${bblue}jumpboxes${bgreen}, please consult for ${bblue}outputs${bgreen} folder - ${bblue}ssh-to-aws${bgreen} scripts to reach any of the deployed jumpboxes"
 	echo -e "${bgreen}- for kubernetes cluster access, please consult for ${bblue}outputs${bgreen} folder for ${bblue}generate-*-kubeconfig${bgreen} scripts to generate and consume kubeconfig files"
	echo -e "- List of provisioned Kubernetes clusters:"	
	export AWS_K8S_CLUSTERS=$(echo ${TFVARS} | jq -c ".k8s_clusters.aws")
	export AWS_K8S_CLUSTERS_COUNT=$(echo ${AWS_K8S_CLUSTERS} | jq length)
	header="\tID\t|\tCLUSTER_NAME\t\t\t|\tREGION\t\t|\tK8S_VERSION\t"
	separator=$(echo -e"$header" | sed 's/./--/g')
	echo "$separator"
	echo -e $header
	echo "$separator"
	for i in $(seq 1 ${AWS_K8S_CLUSTERS_COUNT}); do
		index=$(($i - 1))
		cluster_name=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].name')
		region=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].region')
		k8s_version=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].version')
		if [[ "$cluster_name" == "null" ]]; then
			cluster_name=$NAME_PREFIX-$index-$region
		fi
		echo -e "\t$index\t|\t$cluster_name\t\t|\t$region\t|\t$k8s_version\t"
		done
	echo "$separator"
 	echo -e "${bgreen}- Please consult ${bblue}Getting Started Guide${bgreen} to begin ${bblue}https://docs.tetrate.io/service-express/getting-started/${bgreen}"
	echo -e "${bgreen}- ${bblue}make demo${bgreen} targets are available to fast track the quick start guide, please refer to ${bblue}make help${bgreen} for more information"
	echo -e "${bgreen}- Please consult ${bblue}Tetrate Service Express Documentation${bgreen} for more information ${bblue}https://docs.tetrate.io/service-express/${bgreen}"
fi