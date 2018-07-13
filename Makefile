TAG ?= latest

# crd.Makefile provides targets to install Application CRD.
include ./marketplace-k8s-app-tools/crd.Makefile

# gcloud.Makefile provides default values for
# REGISTRY and NAMESPACE derived from local
# gcloud and kubectl environments.
include ./marketplace-k8s-app-tools/gcloud.Makefile

# marketplace.Makefile provides targets such as
# ".build/marketplace/deployer/envsubst" to build the base
# deployer images locally.
include ./marketplace-k8s-app-tools/marketplace.Makefile

# ubbagent.Makefile provides ".build/ubbagent/ubbagent"
# target to build the ubbagent image locally.
include ./marketplace-k8s-app-tools/ubbagent.Makefile
include ./marketplace-k8s-app-tools/var.Makefile

# app.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined as followed.
include ./marketplace-k8s-app-tools/app.Makefile

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/deployer:1.0
NAME ?= conjur-1
APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)", \
  "imageConjur": "$(REGISTRY)/cyberark/conjur:$(TAG)", \
  "imageUbbagent": "$(REGISTRY)/cyberark/ubbagent:$(TAG)", \
  "reportingSecret": "$(NAME)-reporting-secret" \
}
TESTER_IMAGE ?= $(REGISTRY)/cyberark/conjur-tester:$(TAG)
APP_TEST_PARAMETERS ?= { \
  "imageTester": "$(TESTER_IMAGE)" \
}

# Extend the target as defined in app.Makefile to
# include real dependencies.
app/build:: .build/conjur/deployer \
            .build/conjur/tester \
            .build/conjur/conjur


.build/conjur: | .build
	mkdir -p "$@"

.build/conjur/deployer: apptest/deployer/* \
												apptest/deployer/manifest/* \
												deployer/* \
												manifest/* \
												schema.yaml \
												.build/marketplace/deployer/envsubst \
												.build/var/APP_DEPLOYER_IMAGE \
												.build/var/REGISTRY \
												.build/var/TAG \
												| .build/conjur
	$(call print_target, $@)
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/deployer" \
	    --build-arg TAG="$(TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
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
	docker tag cyberark/conjur "$(REGISTRY)/cyberark/conjur:$(TAG)"
	docker push "$(REGISTRY)/cyberark/conjur:$(TAG)"
	@touch "$@"

# Relocate ubbagent image to $REGISTRY.
.build/conjur/ubbagent: .build/ubbagent/ubbagent \
                           .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/conjur
	$(call print_target, $@)
	docker tag "gcr.io/cloud-marketplace-tools/ubbagent" "$(REGISTRY)/cyberark/ubbagent:$(TAG)"
	docker push "$(REGISTRY)/cyberark/ubbagent:$(TAG)"
	@touch "$@"
