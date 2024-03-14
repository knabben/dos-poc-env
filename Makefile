GITHUB_USER := knabben
REPO_ENV := dos-poc-env

OCI_MANIFEST := oci://ttl.sh/knabben/manifests/dos-poc

ENVS := staging production
REPOS := ttl.sh/knabben/dos-poc ttl.sh/knabben/manifests/dos-poc

.PHONY: 1-up check-env cluster repository
1-up: check-env cluster repository
	kind get clusters

cluster:
	@$(foreach ENV, $(ENVS), kind create cluster --name $(ENV);)

repository:
	@$(foreach ENV, $(ENVS), \
		kubectx kind-$(ENV); \
		flux bootstrap github --token-auth \
		--components-extra=image-reflector-controller,image-automation-controller \
		--owner=$(GITHUB_USER) \
		--repository=$(REPO_ENV) \
		--branch=main \
		--path=clusters/$(ENV) \
		--personal; \
	)

.PHONY: 2-policy
2-policy:
	helm repo add sigstore https://sigstore.github.io/helm-charts
	helm repo update
	@$(foreach ENV, $(ENVS), \
		kubectx kind-$(ENV); \
		kubectl create namespace cosign-system; \
		helm install policy-controller -n cosign-system sigstore/policy-controller --devel; \
	)

.PHONY: 3-slack
3-slack:
	echo


x-delete:
	@$(foreach ENV, $(ENVS), kind delete cluster --name $(ENV);)

x-clean:
	@$(foreach REPO, $(REPOS), \
		crane ls $(REPO) --full-ref | xargs -n1 crane digest | xargs -i -n1 crane delete '$(REPO)@{}'; \
	)

check-env:
ifndef GITHUB_TOKEN
	$(error GITHUB_TOKEN is undefined)
endif

