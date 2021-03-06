#!/bin/bash

source ./colors.sh

REPO_NAMES="\
refarch-cloudnative-micro-inventory \
refarch-cloudnative-micro-catalog \
refarch-cloudnative-micro-customer \
refarch-cloudnative-micro-orders \
refarch-cloudnative-micro-auth \
refarch-cloudnative-micro-web"

# This will be used when building the chart location URL
GIT_ORG="fabiogomezdiaz"

# Also used when building the chart location URL
GIT_BRANCH="master"

# Convenience flag to stash uncommitted work when repackaging the charts
GIT_STASH="no"

# The base URL for the charts location
HELM_REPO_URL=$"https://raw.githubusercontent.com/${GIT_ORG}/refarch-cloudnative-kubernetes/${GIT_BRANCH}/charts"

function helmupdatechart {
	DIRECTORY=$1
	CHART=$2

	printf "\n\n${grn}Updating ${CHART} chart...${end}\n"
	cd $DIRECTORY/chart/$CHART

	if [ "$GIT_STASH" = "yes" ]; then
	  echo "Stashing"
	  git stash
	fi

	helm dependency update
	cd ../..
	helm lint chart/$CHART
	helm package chart/$CHART
	mv  -f *.tgz ../refarch-cloudnative-kubernetes/charts/

	if [ "$GIT_STASH" = "yes" ]; then
	  echo "Popping Stash"
	  git stash pop
	fi

	cd ..
}

cd ../..

helmupdatechart "refarch-cloudnative-micro-auth"      "auth"

helmupdatechart "refarch-cloudnative-micro-customer"  "customer"

helmupdatechart "refarch-cloudnative-micro-inventory" "inventory"

helmupdatechart "refarch-cloudnative-micro-catalog"   "catalog"

helmupdatechart "refarch-cloudnative-micro-orders"    "orders"

helmupdatechart "refarch-cloudnative-micro-web" 	  "web"

printf "\n\n${grn}Reindexing charts Helm repo...${end}\n"
cd refarch-cloudnative-kubernetes

# Re-index helm repo
helm repo index charts --url=${HELM_REPO_URL}

cd scripts