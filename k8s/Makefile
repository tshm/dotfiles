# makefile for installations

.PHONY: ingress cert-manager helm kubeconfig status all

PWD := $(shell readlink -f ${PWD})
SHELL := bash
K := kubectl
DIR := manifest
CONTEXT ?= production

status:;
	@echo showing k8s status for: ${CONTEXT}
	$K cluster-info
	@echo --
	$K get nodes,hpa,svc,deployment -A 

setup:;
	@[ -h .git/hooks/pre-commit ] \
	|| echo -e "#!/bin/sh\ngit-hooks/pre-commit" > .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit

clean_evicted:;
	$K get pods -A --field-selector=status.phase=Failed -o json | $K delete -f -

help:
	@echo targets:
	@echo - create
	@echo - ingress
	@echo - cert-manager
	@echo - config
	@echo - gitops

install:
	$(MAKE) create
	$(MAKE) ingress
	$(MAKE) cert-manager
	$(MAKE) config
	$(MAKE) gitops

# manifest validation
KUSTOMIZE_DIRS := $(patsubst %/kustomization.yaml,%,$(shell find manifest -name kustomization.yaml))
CRDS_SCHEMA_LOCATION := 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'

check: ${KUSTOMIZE_DIRS}

%: %/*.yaml
	@echo Validate manifests: $@
	@$K kustomize $@ | kubeconform -schema-location default \
		-schema-location ${CRDS_SCHEMA_LOCATION} -skip CustomResourceDefinition -summary

k3s:;
	ssh ${K8S_HOST} 'curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE=644 sh -'

config: ${DIR}/initialSetup/*
	$K apply -k ${DIR}/initialSetup

# apply helm charts
stable = https://charts.helm.sh/stable
traefik = https://helm.traefik.io/traefik
jetstack = https://charts.jetstack.io/
crossplane = https://charts.crossplane.io/stable
helm-%:
	helm repo ls | grep $* || helm repo add stable $($*)
helm: helm-stable helm-traefik helm-jetstack helm-crossplane
	helm repo update >/dev/null

crossplane: NS := crossplane-system
crossplane: helm
	$K get ns ${NS} >|/dev/null 2>&1 || $K create ns ${NS}
	helm upgrade --install crossplane crossplane-stable/crossplane \
		--namespace ${NS}

cert-manager: NS := cert-manager
cert-manager: helm
	$K get ns ${NS} >|/dev/null 2>&1 || $K create ns ${NS}
	helm upgrade --install cert-manager jetstack/cert-manager \
		--namespace ${NS} \
		--set installCRDs=true
	$K -n ${NS} wait --for=condition=available deployment/cert-manager
	sleep 20
	$K apply -f ${DIR}/${CONTEXT}/issuer.yaml

ingress: helm
	echo "setting up ingress-controller with hostname: ${HOSTNAME_K8S}"
	helm upgrade --install traefik traefik/traefik --namespace kube-system \
		--set fullnameOverride=traefik \
		--set ssl.enabled=true --set accessLogs.enabled=true \
		--set kubernetes.ingressEndpoint.useDefaultPublishedService=true \
		--set service.annotations."service\.beta\.kubernetes\.io/azure-dns-label-name"=${HOSTNAME_K8S}

gitops: NS := flux-system
gitops: ${DIR}/${CONTEXT}/gitops
	$K apply -k ${<} || { \
		echo 'wait for CRD creation...'; \
		$K -n ${NS} wait --for condition=established --timeout=60s crd/kustomizations.kustomize.toolkit.fluxcd.io; \
		sleep 5; $K apply -k ${<}; }

## this is dummy
flux-bootstrap:
	flux bootstrap git \
	--url=https://host.com/org/repository \
	--username=gitusername \
	--password=gitpasswd \
	--token-auth=true \
	--path=clusters/my-cluster

.kubeconfig:;
	ssh $(K8S_HOST) cat /etc/rancher/k3s/k3s.yaml | sed 's/127.0.0.1/$(K8S_HOST)/' > $@
	# ln -s $@ .kubeconfig

# terraform helpers
destroy: NS := $(shell ${K} config get-contexts -o name)
destroy: kubeconfig
	$K config delete-context ${NS}
	terraform destroy -auto-approve

create:;
	terraform apply -auto-approve
	terraform output -raw kube_config > ${KUBECONFIG}
	make kubeconfig

kubeconfig: NS := $(shell ${K} config get-contexts -o name)
kubeconfig:;
	@echo context is \"${NS}\"
	$K config use-context ${NS}

logging: NS := logging
	FBURL := https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master
logging:
	$K get ns ${NS} >|/dev/null 2>&1 || $K create ns ${NS}
	$K apply -f ${FBURL}/fluent-bit-service-account.yaml
	$K apply -f ${FBURL}/fluent-bit-role-1.22.yaml
	$K apply -f ${FBURL}/fluent-bit-role-binding-1.22.yaml
	$K -n ${NS} apply -k ${DIR}/base/logging

cost: NS := kubecost
cost:
	$K create namespace ${NS}
	helm repo add kubecost https://kubecost.github.io/cost-analyzer/
	helm install kubecost kubecost/cost-analyzer --namespace kubecost --set kubecostToken="dHNobUBjc2MuanA=xm343yadf98"

delete_namespace:
	@if [ "${NS}" == "" ]; then echo 'usage: make delete_namespace -e NS=xxx'; exit 1; fi
	$K get namespace ${NS} -o json | jq '(.spec.finalizers)=[]' > .tmp.json
	$K replace --raw "/api/v1/namespaces/${NS}/finalize" -f .tmp.json
