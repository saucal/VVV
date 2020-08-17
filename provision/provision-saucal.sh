#!/usr/bin/env bash

mkdir -p "/vagrant"
echo "Updating config file early"
if [[ -f "/srv/config/config.yml" ]]; then
	cp -f "/srv/config/config.yml" "/vagrant/config.yml"
fi

SAUCAL_REPO="/var/provisioners/saucal-custom-site-template/"
REPO="https://github.com/saucal/custom-site-template.git"
BRANCH="saucal_version"

rm -rf ${SAUCAL_REPO}
mkdir -p "${SAUCAL_REPO}"

echo -e "\nDownloading SAU/CAL provisioner, git cloning from ${REPO} into ${SAUCAL_REPO}"
git clone --recursive --branch ${BRANCH} ${REPO} ${SAUCAL_REPO} -q
if [ $? -eq 0 ]; then
	echo "SAU/CAL provisioner clone succesful"
else
	echo "Git failed to clone SAU/CAL provisioner. It tried to clone the ${BRANCH} of ${REPO} into ${SAUCAL_REPO}"
	exit 1
fi

for VM_DIR in "$@"
do
    cp -Rf "${SAUCAL_REPO}/provision" "${VM_DIR}"
done