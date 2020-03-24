#!/bin/bash -e

export REGISTRY=${REGISTRY:-'gcr.io/conjur-cloud-launcher-onboard'}
export TAG=${TAG:-"$(whoami)"}

make clean
make crd/install

gcloud auth configure-docker

chart_dir=""
build_target="app/verify"

while [ "$1" != "" ]; do
    case $1 in
        -c | --chart-dir )  shift
                            chart_dir="${1}"
                            ;;
        # Use the -p | --persist flag to keep the application running
        -p | --persist )    build_target="app/install-test"
                            ;;
        * )                 >&2 echo "Unknown argument: ${1}"
                            exit 1
                            ;;
    esac
    shift
done

if [ "${chart_dir}" != "" ]; then
  if [[ ! -f "${chart_dir}/Chart.yaml" ]]; then
    ls -al "${chart_dir}"
    >&2 echo "ERROR: chart directory does not contain a Chart.yaml file"
    exit 1
  fi

  echo "Chart directory specified, switching to dev mode"

  mkdir -p .build
  helm package -d .build --save=false "${chart_dir}"

  export DOCKERFILE=deployer/Dockerfile.dev
  export CONJUR_OSS_PACKAGE="$(ls .build | grep conjur-oss)"
fi

echo "Getting the desired marketplace Docker image..."
MARKETPLACE_TOOLS_TAG="0.10.0"
LOCAL_MARKETPLACE_TOOLS_TAG="local-$USER"
docker pull "gcr.io/cloud-marketplace-tools/k8s/dev:$MARKETPLACE_TOOLS_TAG"
docker tag "gcr.io/cloud-marketplace-tools/k8s/dev:$MARKETPLACE_TOOLS_TAG" \
           "gcr.io/cloud-marketplace-tools/k8s/dev:$LOCAL_MARKETPLACE_TOOLS_TAG"

echo "Building/verifying app..."
make -j4 -e "$build_target"

echo "Done!"
