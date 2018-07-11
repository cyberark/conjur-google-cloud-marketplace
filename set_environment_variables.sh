#!/bin/bash

export APP_NAME=conjur
export APP_DEPLOYER_SERVICEACCOUNT_NAME=$APP_NAME-deployer-sa
export APP_DEPLOYER_IMAGE=us.gcr.io/conjur-cloud-launcher-onboard/cyberark/conjur-deployer
export APP_DEPLOYER_CONFIGMAP_NAME=$APP_NAME-deployer-configmap
export APP_NAMESPACE=default
export APP_PARAMETERS=../deployer/schema.yaml
