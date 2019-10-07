#!/bin/bash

source ./colors.sh

GIT_ORG="fabiogomezdiaz"

REPO_NAMES="\
refarch-cloudnative-micro-inventory \
refarch-cloudnative-micro-catalog \
refarch-cloudnative-micro-customer \
refarch-cloudnative-micro-orders \
refarch-cloudnative-micro-auth \
refarch-cloudnative-micro-web"

COMMIT_MESSAGE="Helm 3 chart format"

cd ../..


for i in ${REPO_NAMES}; do
	printf "${grn}\n\nCommitting changes to ${GIT_ORG}/${i}${end}\n\n";
    cd ${i};
	git add .;
    git commit -m "${COMMIT_MESSAGE}";
	git push;
    cd ..;
done

cd refarch-cloudnative-kubernetes/scripts