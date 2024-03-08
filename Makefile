GITHUB_USER := knabben
REPO_ENV := dos-poc-env

ENVS := staging production

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

.PHONY: 1-up repository

x-delete:
	@$(foreach ENV, $(ENVS), kind delete cluster --name $(ENV);)

check-env:
ifndef GITHUB_TOKEN
	$(error GITHUB_TOKEN is undefined)
endif
