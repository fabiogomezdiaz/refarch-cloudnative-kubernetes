#!/bin/bash

source ./colors.sh

GIT_ORG="fabiogomezdiaz"

REPO_NAMES="\
refarch-cloudnative-micro-inventory \
refarch-cloudnative-micro-catalog \
refarch-cloudnative-micro-customer \
refarch-cloudnative-micro-orders \
refarch-cloudnative-micro-auth \
refarch-cloudnative-micro-web \
refarch-cloudnative-devops-kubernetes"

cd ../..

for i in ${REPO_NAMES}; do
	printf "${grn}\n\nCloning ${GIT_ORG}/${i}${end}\n\n"
	git clone https://github.com/${GIT_ORG}/${i}
	#git clone git@github.com:${GIT_ORG}/${i}
done

cd refarch-cloudnative-kubernetes/scripts