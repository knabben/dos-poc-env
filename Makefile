GITHUB_USER := knabben
REPO_ENV := dos-poc-env
OCI_MANIFEST := oci://ttl.sh/knabben/manifests/dos-poc

ENVS := staging production

.PHONY: 1-up check-env cluster repository
1-up: check-env cluster repository
	kind get clusters

cluster:
	@$(foreach ENV, $(ENVS), kind create cluster --name $(ENV);)

repository:
	@$(foreach ENV, $(ENVS), \
		kubectx kind-$(ENV); \
		flux bootstrap github --token-auth \
		--owner=$(GITHUB_USER) --repository=$(REPO_ENV) \
		--branch=main --path=clusters/$(ENV) --personal; \
	)

2-install:
	@$(foreach ENV, $(ENVS), \
		flux create source oci dos-poc \
		--url=$(OCI_MANIFEST) \
		--tag=latest --interval=1m; \
	)

x-delete:
	@$(foreach ENV, $(ENVS), kind delete cluster --name $(ENV);)

check-env:
ifndef GITHUB_TOKEN
	$(error GITHUB_TOKEN is undefined)
endif
