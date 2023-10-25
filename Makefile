# Functions
.DEFAULT_GOAL := help

.PHONY: all 
all: deploy_infra deploy_tetrate describe ## Deploy the complete demo stack

.PHONY: help
help: Makefile ## Print help
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n"} \
			/^[.a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36mmake %-30s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

.PHONY: deploy_infra
deploy_infra: deploy_infra_aws deploy_addons ## Deploy an underlaying infrastructure
deploy_infra_%: 
	@/bin/sh -c './make/infra_$*.sh deploy'

.PHONY: deploy_addons
deploy_addons: deploy_addons_load-balancer-controller deploy_addons_fluxcd deploy_addons_route53-controller ## Deploy the default addons
deploy_addons_%:
	@/bin/sh -c './make/addons.sh deploy_$*'

.PHONY: deploy_tetrate
deploy_tetrate: deploy_tetrate_managementplane deploy_tetrate_controlplane ## Deploy Tetrate Service Express
deploy_tetrate_%: 
	@/bin/sh -c './make/tetrate_$*.sh deploy'

.PHONY: describe
describe: describe_demo ## Describe the complete demo stack
describe_%:
	@/bin/sh -c './make/describe.sh $*'

.PHONY: demo
demo_01-deploy-application: demo_01-deploy-application ## Deploy the demo application
demo_02-mtls: demo_01-deploy-application demo_02-mtls ## Lunch the mTLS demo
demo_03-zero-trust: demo_01-deploy-application demo_03-zero-trust ## Lunch the Zero Trust demo 
demo_04-publish-service: demo_01-deploy-application demo_04-publish-service ## Lunch the Service Publishing demo
demo_05-publish-api: demo_01-deploy-application demo_05-publish-api ## Lunch the API Publishing demo
demo_all: demo_01-deploy-application demo_02-mtls demo_03-zero-trust demo_04-publish-service demo_05-publish-api ## Setup all demos
demo_%:
	@/bin/sh -c './make/demo.sh $*'

.PHONY: destroy
destroy: destroy_infra destroy_local ## Destroy the complete demo stack

.PHONY: destroy_addons
destroy_addons: destroy_addons_route53-controller destroy_addons_load-balancer-controller## Destroy the infra-integrated addons
destroy_addons_%:
	@/bin/sh -c './make/addons.sh destroy_$*'

.PHONY: destroy_infra
destroy_infra: destroy_addons destroy_infra_aws ## Destroy the underlaying infrastructure
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
