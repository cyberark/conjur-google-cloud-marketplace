ifndef __CRD_MAKEFILE__

__CRD_MAKEFILE__ := included

include common.Makefile

# Installs the application CRD on the cluster.
.PHONY: crd/install
crd/install:
	# Ignore errors on kubectl apply. `AlreadyExists` Errors can occur if
	# another parallel test is doing a kubectl apply at the same time.
	-kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"


# Uninstalls the application CRD from the cluster.
.PHONY: crd/uninstall
crd/uninstall:
	kubectl delete -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"

endif
