# crd.Makefile provides targets to install Application CRD.
include crd.Makefile

# gcloud.Makefile provides default values for
# REGISTRY and NAMESPACE derived from local
# gcloud and kubectl environments.
include gcloud.Makefile

# marketplace.Makefile provides targets such as
# ".build/marketplace/deployer/envsubst" to build the base
# deployer images locally.
include marketplace.Makefile

# ubbagent.Makefile provides ".build/ubbagent/ubbagent"
# target to build the ubbagent image locally.
include var.Makefile

# app.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined as followed.
# This file is forked from https://raw.githubusercontent.com/GoogleCloudPlatform/click-to-deploy/master/k8s/app.Makefile
include app.Makefile

NAME ?= conjur
TAG ?= 1.3
REGISTRY ?= gcr.io/conjur-cloud-launcher-onboard

PREFIX ?= cyberark
APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(PREFIX)/deployer:$(TAG)
CONJUR_IMAGE ?= $(REGISTRY)/$(PREFIX):$(TAG)
POSTGRES_SOURCE_IMAGE ?= postgres:10.1
POSTGRES_IMAGE ?= $(REGISTRY)/$(PREFIX)/postgres:$(TAG)
NGINX_SOURCE_IMAGE ?= nginx:1.15
NGINX_IMAGE ?= $(REGISTRY)/$(PREFIX)/nginx:$(TAG)
DOCKERFILE ?= deployer/Dockerfile

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}
TESTER_IMAGE ?= $(REGISTRY)/$(PREFIX)/tester:$(TAG)
APP_TEST_PARAMETERS ?= { \
  "tester.image": "$(TESTER_IMAGE)" \
}

# Extend the target as defined in app.Makefile to
# include real dependencies.
app/build:: .build/conjur/deployer \
            .build/conjur/conjur \
            .build/conjur/postgres \
            .build/conjur/nginx \
            .build/conjur/tester

.build/conjur: | .build
	mkdir -p "$@"

.build/conjur/deployer: apptest/deployer/* \
                        apptest/deployer/conjur/* \
                        apptest/deployer/conjur/templates/* \
                        deployer/* \
                        conjur/* \
                        conjur/templates/* \
                        schema.yaml \
                        .build/var/REGISTRY \
                        .build/var/TAG \
                        | .build/conjur
	$(call print_target, $@)
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg CONJUR_OSS_PACKAGE="$(CONJUR_OSS_PACKAGE)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f "$(DOCKERFILE)" \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"

.build/conjur/tester:
	$(call print_target, $@)
	docker pull cosmintitei/bash-curl
	docker tag cosmintitei/bash-curl "$(TESTER_IMAGE)"
	docker push "$(TESTER_IMAGE)"
	@touch "$@"

# Simulate building of primary app image. Actually just copying public image to
# local registry.
.build/conjur/conjur: .build/var/REGISTRY \
                            .build/var/TAG \
                            | .build/conjur
	$(call print_target, $@)
	docker pull cyberark/conjur
	docker tag cyberark/conjur "$(CONJUR_IMAGE)"
	docker push "$(CONJUR_IMAGE)"
	@touch "$@"

# Relocate postgres image to $REGISTRY
.build/conjur/postgres: .build/var/REGISTRY \
												| .build/conjur
	$(call print_target, $@)
	docker pull $(POSTGRES_SOURCE_IMAGE)
	docker tag "$(POSTGRES_SOURCE_IMAGE)" "$(POSTGRES_IMAGE)"
	docker push "$(POSTGRES_IMAGE)"
	@touch "$@"

# Relocate NGINX image to $REGISTRY
.build/conjur/nginx: .build/var/REGISTRY \
												| .build/conjur
	$(call print_target, $@)
	docker pull $(NGINX_SOURCE_IMAGE)
	docker tag "$(NGINX_SOURCE_IMAGE)" "$(NGINX_IMAGE)"
	docker push "$(NGINX_IMAGE)"
	@touch "$@"
