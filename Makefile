# Functions
.DEFAULT_GOAL := help

.PHONY: all 
all: deploy_infra deploy_tetrate ## Deploy the complete demo stack

.PHONY: help
help: Makefile ## Print help
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n"} \
			/^[.a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36mmake %-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

.PHONY: deploy_infra
deploy_infra: deploy_infra_aws ## Deploy an underlaying infrastructure
deploy_infra_%: 
	@/bin/sh -c './make/infra_$*.sh deploy'

.PHONY: deploy_tetrate
deploy_tetrate: deploy_tetrate_managementplane deploy_tetrate_controlplane ## Deploy Tetrate Service Express
deploy_tetrate_%: 
	@/bin/sh -c './make/tetrate_$*.sh deploy'

.PHONY: describe_demo
describe_demo: describe_tetrate ## Describe the complete demo stack
describe_%:
	@/bin/sh -c './make/describe.sh $*'

.PHONY: destroy
destroy: destroy_infra destroy_local ## Destroy the complete demo stack

.PHONY: destroy_infra
destroy_infra: destroy_infra_aws ## Destroy the underlaying infrastructure
destroy_infra_%: 
	@/bin/sh -c './make/infra_$*.sh destroy'

.PHONY: destroy_local
destroy_local:  ## Destroy the local Terraform state and cache
	@$(MAKE) destroy_tfstate
	@$(MAKE) destroy_tfcache
	@$(MAKE) destroy_outputs

.PHONY: destroy_tfstate
destroy_tfstate:
	find . -name *tfstate* -exec rm -rf {} +

.PHONY: destroy_tfcache
destroy_tfcache:
	find . -name .terraform -exec rm -rf {} +
	find . -name .terraform.lock.hcl -delete

.PHONY: destroy_outputs
destroy_outputs:
	rm -f outputs/*-kubeconfig.sh outputs/*-jumpbox.sh outputs/*-kubeconfig outputs/*.jwk outputs/*.pem outputs/*-cleanup.sh
	rm -f outputs/terraform_outputs/*.json
