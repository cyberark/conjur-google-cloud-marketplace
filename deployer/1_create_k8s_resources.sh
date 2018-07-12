#!/bin/bash

if ! has_serviceaccount $DEPLOYER_SERVICEACCOUNT_NAME; then
  echo "Creating '$DEPLOYER_SERVICEACCOUNT_NAME' service account in namespace $NAMESPACE"
  kubectl create serviceaccount $DEPLOYER_SERVICEACCOUNT_NAME -n $NAMESPACE
fi

####################
# Helper functions #
####################
has_serviceaccount() {
  kuberctl get serviceaccount "$1" &> /dev/null;
}

has_configmap() {
  kuberctl get configmap "$1" &> /dev/null;
}