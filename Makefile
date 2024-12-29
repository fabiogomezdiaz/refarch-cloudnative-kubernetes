.PHONY: init clean install all

# Cleanup target
clean:

# Prompt user for app and api ingress FQDNs and install Helm chart
install:
	@read -p "Enter App Ingress FQDN: " APP_FQDN; \
	read -p "Enter API Ingress FQDN: " API_FQDN; \
	helm upgrade --install bluecompute charts/bluecompute-0.0.9.tgz \
	--namespace bluecompute --create-namespace \
	--values bluecompute/values.yaml \
	--set ingress.enabled=true \
	--set ingress.hostnames.app=$$APP_FQDN \
	--set ingress.hostnames.api=$$API_FQDN

# Default target
all: install