TAG ?= 1.3

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
include ./marketplace-k8s-app-tools/var.Makefile

# app.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined as followed.
include ./marketplace-k8s-app-tools/app.Makefile

NAME ?= conjur

PREFIX ?= cyberark
APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(PREFIX)/deployer:$(TAG)
CONJUR_IMAGE ?= $(REGISTRY)/$(PREFIX):$(TAG)
POSTGRES_SOURCE_IMAGE ?= postgres:10.1
POSTGRES_IMAGE ?= $(REGISTRY)/$(PREFIX)/postgres:$(TAG)
NGINX_SOURCE_IMAGE ?= nginx:1.15
NGINX_IMAGE ?= $(REGISTRY)/$(PREFIX)/nginx:$(TAG)

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)", \
  "conjur.image": "$(CONJUR_IMAGE)", \
  "postgres.image": "$(POSTGRES_IMAGE)" \
  "nginx.image": "$(NGINX_IMAGE)" \
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
