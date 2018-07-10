#!/bin/bash

if ! has_serviceaccount $DEPLOYER_SERVICEACCOUNT_NAME; then
  echo "Creating '$DEPLOYER_SERVICEACCOUNT_NAME' service account in namespace $NAMESPACE"
  kubectl create serviceaccount $DEPLOYER_SERVICEACCOUNT_NAME -n $NAMESPACE

  if [[ "$PLATFORM" == "openshift" ]]; then
    # allow pods with conjur-cluster serviceaccount to run as root
    oc adm policy add-scc-to-user anyuid "system:serviceaccount:$NAMESPACE:$DEPLOYER_SERVICEACCOUNT_NAME"
  fi
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