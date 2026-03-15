#!/bin/bash

set -e

DOCKER_TAG=$1
DOCKER_FILE=$2
DOCKER_BUILD_EXTRA=$3

if [[ -z "${DOCKER_TAG}" ]] || [[ -z "${DOCKER_FILE}" ]]; then
   echo "USAGE $0 DOCKER_TAG DOCKER_FILE [DOCKER_BUILD_EXTRA]"
   exit 1
fi

if [[ -z "${DOCKER_REUSE_DAYS}" ]]; then
   DOCKER_REUSE_DAYS=7
fi

if [ -z "$(docker images -q "${DOCKER_TAG}" 2> /dev/null)" ]; then
    echo "Image ${DOCKER_TAG} does not exists."
else
    IMAGE_DATE_TZ=$(docker inspect -f '{{ .Created }}' ${DOCKER_TAG})
    IMAGE_DATE_UNIX=$(date -d "${IMAGE_DATE_TZ}" +%s)

    NOW=$(date +%s)
    IMAGE_AGE_SECONDS=$((NOW-IMAGE_DATE_UNIX))
    IMAGE_AGE_DAYS=$((IMAGE_AGE_SECONDS/86400))

    echo "The ${DOCKER_TAG} image has ${IMAGE_AGE_DAYS} days (${IMAGE_AGE_SECONDS} seconds)"

    if (( IMAGE_AGE_DAYS > DOCKER_REUSE_DAYS )); then
        echo "Image is older than ${DOCKER_REUSE_DAYS} days. Forcing build without cache."
        DOCKER_BUILD_EXTRA="${DOCKER_BUILD_EXTRA} --no-cache"
    else
        echo "Image is newer than ${DOCKER_REUSE_DAYS} days."
    fi
fi

docker build ${DOCKER_BUILD_EXTRA} -t "${DOCKER_TAG}" -f "ci/${DOCKER_FILE}" .
