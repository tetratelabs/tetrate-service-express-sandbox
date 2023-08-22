#!/usr/bin/env bash

export ROOT_DIR="$(
	cd -- "$(dirname "${0}")" >/dev/null 2>&1
	pwd -P
)"
source ${ROOT_DIR}/variables.sh

export ACTION=${1}

if [[ ${ACTION} = "describe" ]]; then
	source ${ROOT_DIR}/describe.sh demo
fi

init_kubeconfig() {
  local index="$1"
  local cluster_name="$2"
  local region="$3"
  command="eksctl utils write-kubeconfig --cluster ${cluster_name} --region ${region} --kubeconfig .kube/config"
  (    
    run_command_at_jumpbox $index $command
  )
}

if [[ ${ACTION} = "deploy_application" ]]; then
  print_info "Deploying application... as per https://docs.tetrate.io/service-express/getting-started/deploy-application"
	export index=0
  export AWS_K8S_CLUSTERS=$(echo ${TFVARS} | jq -c ".k8s_clusters.aws")
  cluster_name=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].name')
  region=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].region')
  k8s_version=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].version')
  if [[ "$cluster_name" == "null" ]]; then
    cluster_name=$NAME_PREFIX-$index-$region
  fi
  init_kubeconfig $index $cluster_name $region
  print_info "Check if demo directory exists, if not create..."
  run_command_at_jumpbox $index "if [ ! -d demo ]; then git clone ${GIT_REPO}; cp -r tetrate-service-express-sandbox/demo . ;fi"
  print_info "Deploy an application to a TSE-managed cluster..."
  run_command_at_jumpbox $index './demo/scripts/getting_started_guide/01-deploy-application.sh'
fi

if [[ ${ACTION} = "mtls" ]]; then
  print_info "Enforce Encryption with Mutual TLS... as per https://docs.tetrate.io/service-express/getting-started/mtls"
	export index=0
  export AWS_K8S_CLUSTERS=$(echo ${TFVARS} | jq -c ".k8s_clusters.aws")
  cluster_name=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].name')
  region=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].region')
  k8s_version=$(echo $AWS_K8S_CLUSTERS | jq -cr '.['$index'].version')
  if [[ "$cluster_name" == "null" ]]; then
    cluster_name=$NAME_PREFIX-$index-$region
  fi
  init_kubeconfig $index $cluster_name $region
  print_info "Check if demo directory exists, if not create..."
  run_command_at_jumpbox $index "if [ ! -d demo ]; then git clone ${GIT_REPO}; cp -r tetrate-service-express-sandbox/demo . ;fi"
  print_info "Enforce Encryption with Mutual TLS..."
  run_command_at_jumpbox $index './demo/scripts/getting_started_guide/02-mtls.sh'
fi