# Functions
.DEFAULT_GOAL := help

.PHONY: all 
all: deploy_infra ## Deploy the complete demo stack

.PHONY: help
help: Makefile ## Print help
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n"} \
			/^[.a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36mmake %-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

.PHONY: deploy_infra
deploy_infra: deploy_infra_aws ## Deploy an underlaying infrastructure
deploy_infra_%: 
	@/bin/sh -c './make/infra_$*.sh deploy'

.PHONY: deploy_tetrate
deploy_tetrate: deploy_tetrate_managementplane ## Deploy Tetrate Service Express
deploy_tetrate_%: 
	@/bin/sh -c './make/tetrate_$*.sh deploy'


.PHONY: destroy_infra
destroy_infra: destroy_infra_aws ## Destroy the underlaying infrastructure
destroy_infra_%: 
	@/bin/sh -c './make/infra_$*.sh destroy'