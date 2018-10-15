#!/bin/bash -e

DOCKER_BUILD_DIR="."
DOCKER_TARGET="baseimage-fatjar:latest"
docker build -t ${DOCKER_TARGET} ${DOCKER_BUILD_DIR}
