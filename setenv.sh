#!/bin/bash

export NAME=conjur
export NAMESPACE="$(whoami)"

export REGISTRY=us.gcr.io/conjur-cloud-launcher-onboard

export DEPLOYER_SERVICEACCOUNT_NAME=$APP_NAME-deployer-sa
export DEPLOYER_IMAGE=$REGISTRY/cyberark/conjur-deployer
export DEPLOYER_CONFIGMAP_NAME=$APP_NAME-deployer-configmap

export PARAMETERS=schema.yaml
