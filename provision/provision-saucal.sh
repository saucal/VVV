#!/usr/bin/env bash

VM_DIR=$1
SAUCAL_REPO="/var/provisioners/saucal-custom-site-template/"
REPO="https://github.com/saucal/custom-site-template.git"
BRANCH="saucal_version"

mkdir -p "${SAUCAL_REPO}"

if [[ -d ${SAUCAL_REPO}/.git ]]; then
	echo -e "\nUpdating SAU/CAL provisioner in ${SAUCAL_REPO}..."
	cd ${SAUCAL_REPO}
	git reset origin/${BRANCH} --hard -q
	git pull origin ${BRANCH} -q
	git checkout ${BRANCH} -q
else
	echo -e "\nDownloading SAU/CAL provisioner, git cloning from ${REPO} into ${SAUCAL_REPO}"
	git clone --recursive --branch ${BRANCH} ${REPO} ${SAUCAL_REPO} -q
	if [ $? -eq 0 ]; then
		echo "SAU/CAL provisioner clone succesful"
	else
		echo "Git failed to clone SAU/CAL provisioner. It tried to clone the ${BRANCH} of ${REPO} into ${SAUCAL_REPO}"
		exit 1
	fi
fi

cp -Rf ${SAUCAL_REPO}/provision ${VM_DIR}/provision