#!/bin/bash -e

make clean
make crd/install

gcloud auth configure-docker

echo "Getting the desired marketplace Docker image..."
MARKETPLACE_TOOLS_TAG="0.7.0"
LOCAL_MARKETPLACE_TOOLS_TAG="local-$USER"
docker pull "gcr.io/cloud-marketplace-tools/k8s/dev:$MARKETPLACE_TOOLS_TAG"
docker tag "gcr.io/cloud-marketplace-tools/k8s/dev:$MARKETPLACE_TOOLS_TAG" \
           "gcr.io/cloud-marketplace-tools/k8s/dev:$LOCAL_MARKETPLACE_TOOLS_TAG"

echo "Building/verifying app..."
env \
  TAG="${CI_COMMIT_SHA:-$(whoami)}" \
  REGISTRY='gcr.io/conjur-gke-dev' \
  make -j4 -e app/verify

echo "Done!"
