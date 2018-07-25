#!/bin/bash -e

make clean
make crd/install

env \
  TAG="${CI_COMMIT_SHA:-$(whoami)}" \
  REGISTRY='gcr.io/conjur-gke-dev' \
  make -e app/verify
