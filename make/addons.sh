#!/usr/bin/env bash


export ROOT_DIR="$(
	cd -- "$(dirname "${0}")" >/dev/null 2>&1
	pwd -P
)"
source ${ROOT_DIR}/variables.sh

export ACTION=${1}

if [[ ${ACTION} = "deploy_load-balancer-controller" ]]; then
	source ${ROOT_DIR}/k8s_auth.sh refresh
	cd "${ROOT_DIR}/../addons/aws/load-balancer-controller"
	export AWS_K8S_CLUSTERS=$(echo ${TFVARS} | jq -c ".k8s_clusters.aws")
	export AWS_K8S_CLUSTERS_COUNT=$(echo ${AWS_K8S_CLUSTERS} | jq length)
	for i in $(seq 1 ${AWS_K8S_CLUSTERS_COUNT}); do
		index=$(($i - 1))
		cluster_name=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].name')
		region=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].region')
		k8s_version=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].version')
		if [[ "$cluster_name" == "null" ]]; then
			cluster_name=$NAME_PREFIX-$index-$region
		fi
		terraform workspace new aws-$index-$region || true
		terraform workspace select aws-$index-$region
		terraform init
		terraform apply ${TERRAFORM_APPLY_ARGS} -var-file="../../../terraform.tfvars.json" \
			-var=cluster_id=$index -var=region=$region
		terraform output ${TERRAFORM_OUTPUT_ARGS} | jq . >../../../outputs/terraform_outputs/terraform-aws-load-balancer-controller-$index-$cluster_name.json
		terraform workspace select default
	done
	cd "../../.."
fi

if [[ ${ACTION} = "destroy_load-balancer-controller" ]]; then
	source ${ROOT_DIR}/k8s_auth.sh refresh
	cd "${ROOT_DIR}/../addons/aws/load-balancer-controller"
	export AWS_K8S_CLUSTERS=$(echo ${TFVARS} | jq -c ".k8s_clusters.aws")
	export AWS_K8S_CLUSTERS_COUNT=$(echo ${AWS_K8S_CLUSTERS} | jq length)
	for i in $(seq 1 ${AWS_K8S_CLUSTERS_COUNT}); do
		index=$(($i - 1))
		cluster_name=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].name')
		region=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].region')
		k8s_version=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].version')
		if [[ "$cluster_name" == "null" ]]; then
			cluster_name=$NAME_PREFIX-$index-$region
		fi
		terraform workspace new aws-$index-$region || true
		terraform workspace select aws-$index-$region
		terraform init
		terraform destroy ${TERRAFORM_APPLY_ARGS} -var-file="../../../terraform.tfvars.json" \
			-var=cluster_id=$index -var=region=$region
		terraform workspace select default
	done
	cd "../../.."
fi

if [[ ${ACTION} = "deploy_route53-controller" ]]; then
	source ${ROOT_DIR}/k8s_auth.sh refresh
	cd "${ROOT_DIR}/../addons/aws/route53-controller"
	export AWS_K8S_CLUSTERS=$(echo ${TFVARS} | jq -c ".k8s_clusters.aws")
	export AWS_K8S_CLUSTERS_COUNT=$(echo ${AWS_K8S_CLUSTERS} | jq length)
	for i in $(seq 1 ${AWS_K8S_CLUSTERS_COUNT}); do
		index=$(($i - 1))
		cluster_name=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].name')
		region=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].region')
		k8s_version=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].version')
		external_dns_zone=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].external_dns_zone')
		if [[ "$cluster_name" == "null" ]]; then
			cluster_name=$NAME_PREFIX-$index-$region
		fi
		if [[ "$external_dns_zone" != "null" ]]; then
			terraform workspace new aws-$index-$region || true
			terraform workspace select aws-$index-$region
			terraform init
			terraform apply ${TERRAFORM_APPLY_ARGS} -var-file="../../../terraform.tfvars.json" \
				-var=cluster_id=$index -var=region=$region -var=external_dns_aws_dns_zone=$external_dns_zone
			terraform output ${TERRAFORM_OUTPUT_ARGS} | jq . >../../../outputs/terraform_outputs/terraform-aws-route53-controller-$index-$cluster_name.json
			terraform workspace select default
		fi
	done
	cd "../../.."
fi

if [[ ${ACTION} = "destroy_route53-controller" ]]; then
	source ${ROOT_DIR}/k8s_auth.sh refresh
	cd "${ROOT_DIR}/../addons/aws/route53-controller"
	export AWS_K8S_CLUSTERS=$(echo ${TFVARS} | jq -c ".k8s_clusters.aws")
	export AWS_K8S_CLUSTERS_COUNT=$(echo ${AWS_K8S_CLUSTERS} | jq length)
	for i in $(seq 1 ${AWS_K8S_CLUSTERS_COUNT}); do
		index=$(($i - 1))
		cluster_name=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].name')
		region=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].region')
		k8s_version=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].version')
		external_dns_zone=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].external_dns_zone')
		if [[ "$cluster_name" == "null" ]]; then
			cluster_name=$NAME_PREFIX-$index-$region
		fi
		if [[ "$external_dns_zone" != "null" ]]; then
			terraform workspace new aws-$index-$region || true
			terraform workspace select aws-$index-$region
			terraform init
			terraform destroy ${TERRAFORM_APPLY_ARGS} -var-file="../../../terraform.tfvars.json" \
				-var=cluster_id=$index -var=region=$region -var=external_dns_aws_dns_zone=$external_dns_zone -target=module.route53-controller.aws_iam_policy.policy_service_account \
				-target=module.route53-controller.aws_iam_role.role_service_account -target=module.route53-controller.aws_iam_role_policy_attachment.policy_attachment_service_account \
				-target=module.route53-controller.kubernetes_service_account.service_account -target=module.route53-controller.local_file.aws_cleanup \
				-target=module.route53-controller.null_resource.aws_cleanup
			terraform workspace select default
		fi
	done
	cd "../../.."
fi

if [[ ${ACTION} = "deploy_fluxcd" ]]; then
	source ${ROOT_DIR}/k8s_auth.sh refresh
	cd "${ROOT_DIR}/../addons/fluxcd"
	export AWS_K8S_CLUSTERS=$(echo ${TFVARS} | jq -c ".k8s_clusters.aws")
	export AWS_K8S_CLUSTERS_COUNT=$(echo ${AWS_K8S_CLUSTERS} | jq length)
	for i in $(seq 1 ${AWS_K8S_CLUSTERS_COUNT}); do
		index=$(($i - 1))
		cluster_name=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].name')
		region=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].region')
		k8s_version=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].version')
		if [[ "$cluster_name" == "null" ]]; then
			cluster_name=$NAME_PREFIX-$index-$region
		fi
		terraform workspace new aws-$index-$region || true
		terraform workspace select aws-$index-$region
		terraform init
		terraform apply ${TERRAFORM_APPLY_ARGS} -var-file="../../terraform.tfvars.json" \
			-var=cluster_id=$index -var=region=$region
		terraform output ${TERRAFORM_OUTPUT_ARGS} | jq . >../../outputs/terraform_outputs/terraform-fluxcd-$index-$cluster_name.json
		terraform workspace select default
	done
	cd "../.."
fi