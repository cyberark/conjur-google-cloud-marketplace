FROM launcher.gcr.io/google/debian9 AS build

# Cachebuster is used to forcefully invalidate the cache when needed
RUN echo "cachebuster-20190116" >/dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends gettext curl

RUN curl -L -o /tmp/helm.tgz https://storage.googleapis.com/kubernetes-helm/helm-v2.6.1-linux-amd64.tar.gz && \
    cd /tmp && \
    tar xvzf helm.tgz && \
    cp linux-amd64/helm /usr/local/bin/helm && \
    rm -rf helm.tgz linux-amd64

RUN helm init --client-only && \
    helm repo add cyberark https://cyberark.github.io/helm-charts

COPY ./conjur /tmp/chart
WORKDIR /tmp/chart

RUN helm dep update .

WORKDIR /tmp
RUN tar -czvf conjur.tar.gz chart

COPY apptest/deployer/conjur /tmp/test/chart
WORKDIR /tmp/test

RUN tar -czvf conjur.tar.gz chart

COPY schema.yaml /tmp/schema.yaml
COPY apptest/deployer/schema.yaml /tmp/test/schema.yaml

# Provide registry prefix and tag for default values for images.
ARG REGISTRY
ARG TAG
RUN cat /tmp/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /tmp/schema.yaml.new \
    && mv /tmp/schema.yaml.new /tmp/schema.yaml
RUN cat /tmp/test/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /tmp/test/schema.yaml.new \
    && mv /tmp/test/schema.yaml.new /tmp/test/schema.yaml


FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm:0.7.0
COPY --from=build /tmp/conjur.tar.gz /data/chart/
COPY --from=build /tmp/test/conjur.tar.gz /data-test/chart/
COPY --from=build /tmp/schema.yaml /data/
COPY --from=build /tmp/test/schema.yaml /data-test/
