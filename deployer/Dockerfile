FROM launcher.gcr.io/google/debian9 AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends gettext

ADD conjur /tmp/chart
RUN cd /tmp \
    && tar -czvf /tmp/conjur.tar.gz chart
ADD apptest/deployer/conjur /tmp/test/chart
RUN cd /tmp/test \
    && tar -czvf /tmp/test/conjur.tar.gz chart/

ADD schema.yaml /tmp/schema.yaml
ADD apptest/deployer/schema.yaml /tmp/test/schema.yaml

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


FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm:v0.6.2
COPY --from=build /tmp/conjur.tar.gz /data/chart/
COPY --from=build /tmp/test/conjur.tar.gz /data-test/chart/
COPY --from=build /tmp/schema.yaml /data/
COPY --from=build /tmp/test/schema.yaml /data-test/