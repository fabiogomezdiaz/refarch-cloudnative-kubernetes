.PHONY: init clean install all

# Cleanup target
clean:

# Prompt user for app and api ingress FQDNs and install Helm chart
install:
	# helm dependency update bluecompute; \
	helm upgrade --install bluecompute bluecompute \
	--namespace bluecompute --create-namespace \
	--values bluecompute/values.yaml # --dry-run --debug

install-ingress:
	@read -p "Enter App Ingress FQDN: " APP_FQDN; \
	read -p "Enter API Ingress FQDN: " API_FQDN; \
	helm dependency update bluecompute; \
	set -x; \
	helm upgrade --install bluecompute bluecompute \
	--namespace bluecompute --create-namespace \
	--values bluecompute/values.yaml \
	--set ingress.enabled=true \
	--set ingress.hostnames.app=$$APP_FQDN \
	--set ingress.hostnames.api=$$API_FQDN # --dry-run --debug

install-storage-ingress:
	@read -p "Enter App Ingress FQDN: " APP_FQDN; \
	read -p "Enter API Ingress FQDN: " API_FQDN; \
	helm dependency update bluecompute; \
	set -x; \
	helm upgrade --install bluecompute bluecompute \
	--namespace bluecompute --create-namespace \
	--values bluecompute/values-storage.yaml \
	--set ingress.enabled=true \
	--set ingress.hostnames.app=$$APP_FQDN \
	--set ingress.hostnames.api=$$API_FQDN # --dry-run --debug

delete:
	helm delete bluecompute --namespace bluecompute

# Default target
all: install