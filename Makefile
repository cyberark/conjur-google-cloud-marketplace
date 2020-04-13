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
TAG ?= $(shell cat VERSION)
REGISTRY ?= gcr.io/conjur-cloud-launcher-onboard
COMPANY ?= cyberark
APPLICATION ?= conjur-open-source

# The following Conjur release image is used for (copied to) the Marketplace
# application image. To minimize confusion, the minor (or "track") version
# of the Marketplace application should match the minor version of the
# Conjur release that it uses (e.g. both can have minor versions of 1.6).
CONJUR_RELEASE_TAG ?= 1.6
CONJUR_RELEASE_REPO ?= cyberark/conjur
CONJUR_RELEASE_IMAGE ?= $(CONJUR_RELEASE_REPO):$(CONJUR_RELEASE_TAG)

APP_REPO ?= $(REGISTRY)/$(COMPANY)/$(APPLICATION)
APP_IMAGE ?= $(APP_REPO):$(TAG)
DEPLOYER_DOCKERFILE ?= deployer/Dockerfile
APP_DEPLOYER_IMAGE ?= $(APP_REPO)/deployer:$(TAG)
POSTGRES_SOURCE_IMAGE ?= postgres:10.1
POSTGRES_IMAGE ?= $(APP_REPO)/postgres:$(TAG)
NGINX_SOURCE_IMAGE ?= nginx:1.17
NGINX_IMAGE ?= $(APP_REPO)/nginx:$(TAG)
TESTER_DOCKERFILE ?= tester/Dockerfile
TESTER_IMAGE ?= $(APP_REPO)/tester:$(TAG)

$(info ---- COMPANY = ${COMPANY})
$(info ---- APPLICATION = ${APPLICATION})
$(info ---- TAG = ${TAG})
$(info ---- APP_IMAGE = ${APP_IMAGE})
$(info ---- CONJUR_RELEASE_IMAGE = ${CONJUR_RELEASE_IMAGE})

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}
APP_TEST_PARAMETERS ?= { \
  "tester.image": "$(TESTER_IMAGE)", \
  "conjur-oss.ssl.hostname": "$(CERTIFICATE_CN)" \
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
	# Note: print_target displays a highlighted (in yellow) message
	# indicating the target that is being built.
	$(call print_target, $@)
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)" \
	    --build-arg TAG="$(TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f "$(DEPLOYER_DOCKERFILE)" \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"

.build/conjur/tester:
	$(call print_target, $@)
	docker build \
	    --tag "$(TESTER_IMAGE)" \
	    -f "$(TESTER_DOCKERFILE)" \
	    .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"

# Simulate building of primary app image. Actually just copying public image to
# local registry.
.build/conjur/conjur: .build/var/REGISTRY \
                            .build/var/TAG \
                            | .build/conjur
	$(call print_target, $@)
	docker pull "$(CONJUR_RELEASE_IMAGE)"
	docker tag "$(CONJUR_RELEASE_IMAGE)" "$(APP_IMAGE)"
	docker push "$(APP_IMAGE)"
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
