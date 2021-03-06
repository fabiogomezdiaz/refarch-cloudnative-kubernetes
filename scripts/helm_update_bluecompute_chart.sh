#!/bin/bash

source ./colors.sh

REPO_NAME="refarch-cloudnative-kubernetes"

# This will be used when building the chart location URL
GIT_ORG="fabiogomezdiaz"

# Also used when building the chart location URL
GIT_BRANCH="master"

# Convenience flag to stash uncommitted work when repackaging the charts
GIT_STASH="no"

# Chart name
CHART="bluecompute"

# Helm repo location in git repo
HELM_REPO_LOCATION="charts"

# The Base URL for the chart location
HELM_REPO_URL=$"https://raw.githubusercontent.com/${GIT_ORG}/${REPO_NAME}/${GIT_BRANCH}/${HELM_REPO_LOCATION}"

if [ "$GIT_STASH" = "yes" ]; then
  echo "Stashing"
  git stash
fi

helm repo add ibmcase ${HELM_REPO_URL}
helm repo update

printf "\n\n${grn}Updating ${CHART} chart...${end}\n"
cd ../$CHART

helm dependency update
cd ..
helm lint $CHART
helm package $CHART
mv  -f *.tgz ${HELM_REPO_LOCATION}

if [ "$GIT_STASH" = "yes" ]; then
  echo "Popping Stash"
  git stash pop
fi

printf "\n\n${grn}Reindexing charts Helm repo...${end}\n"

helm repo index ${HELM_REPO_LOCATION} --url=${HELM_REPO_URL}

cd scripts