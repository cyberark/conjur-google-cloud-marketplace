# Overview

----
**NOTICE: This project has no releases compatible with current K8s versions or latest releases
of Conjur OSS. Please consider other [deployment methods](https://docs.conjur.org/Latest/en/Content/OSS/Installation/Install_methods.htm) instead - in particular, consider deploying using the
[helm chart](https://github.com/cyberark/conjur-oss-helm-chart) directly.**

If you have any questions, please contact the maintainers on [Discourse](https://discuss.cyberarkcommons.org).

----

CyberArk Conjur automatically secures secrets used by privileged users and machine identities.

[Learn more.](https://www.conjur.org)

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks!
Install this Conjur app to a Google Kubernetes Engine cluster using Google Cloud Marketplace.
Follow the [on-screen instructions](https://console.cloud.google.com/marketplace/details/cyberark/conjur-open-source).

## Command line instructions

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment:
- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [helm](https://github.com/helm/helm)
- [docker](https://docs.docker.com/install/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine cluster

Create a new cluster from the command line:

```shell
export CLUSTER=conjur-cluster
export ZONE=us-central1-a

gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```

Configure `kubectl` to connect to the new cluster:

```shell
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

#### Clone this repo

Clone this repo and the associated tools repo:

```shell
git submodule sync --recursive
git submodule update --recursive --init --force
```

#### Install the Application resource definition

An Application resource is a collection of individual Kubernetes components,
such as Services, Deployments, and so on, that you can manage as a group.

To set up your cluster to understand Application resources, run the following command:

```shell
kubectl apply -f marketplace-k8s-app-tools/crd/*
```

You need to run this command once.

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

#### Configure the app with environment variables

Choose the namespace for the app.

```shell
export NAMESPACE=conjur
```

Choose a DNS hostname to be used as a CA certificate common name:

```shell
export CERTIFICATE_CN=conjur.myorg.com
```

Configure the container images:

```shell
export TAG_VERSION=$(cat VERSION)
export CONJUR_REPO="gcr.io/cloud-marketplace/cyberark/conjur-open-source"
export POSTGRES_REPO="$CONJUR_REPO/postgres"
export NGINX_REPO="$CONJUR_REPO/nginx"
```

#### Create namespace in your Kubernetes cluster

We recommend running Conjur in its own namespace.
If you use a different namespace than the `default`, run the command below to create a new namespace:

```shell
kubectl create namespace "$NAMESPACE"
kubectl config set-context --current --namespace="$NAMESPACE"
```

#### Install the application with Helm (v2 or v3) to your Kubernetes cluster

These instructions assume that your local `helm` client is version 2 or version 3.

This project uses the upstream [cyberark/conjur-oss Helm chart](https://github.com/cyberark/conjur-oss-helm-chart). (You do not need to clone or helm install this repo directly; this will be done indirectly via the helm install of conjur below.)

Use `helm` to deploy the application to your Kubernetes cluster:

If you'd like to use an external database, 
use the `helm` argument `--set conjuross.databaseUrl='postgresql://[user[:password]@][netloc][:port][/dbname][?param1=value1&...]'` below. If `conjuross.databaseUrl` is not specified, a postgres deployment and service are created.
See [conjur/values.yaml](conjur/values.yaml) for all available parameters and their defaults.
See [conjur-oss/values.yaml](https://github.com/cyberark/conjur-oss-helm-chart/blob/master/conjur-oss/values.yaml)
for all available upstream Helm chart parameters and their defaults.

```shell
helm dependency update ./conjur
helm install conjur \
     --set conjur-oss.ssl.hostname="$CERTIFICATE_CN" \
     --set conjur-oss.dataKey="$(docker run --rm cyberark/conjur data-key generate)" \
     --set conjur-oss.image.repository="$CONJUR_REPO" \
     --set conjur-oss.image.tag="$TAG_VERSION" \
     --set conjur-oss.image.pullPolicy="Always" \
     --set conjur-oss.nginx.image.repository="$NGINX_REPO" \
     --set conjur-oss.nginx.image.tag="$TAG_VERSION" \
     --set conjur-oss.nginx.image.pullPolicy="Always" \
     --set conjur-oss.postgres.image.repository="$POSTGRES_REPO" \
     --set conjur-oss.postgres.image.tag="$TAG_VERSION" \
     --set conjur-oss.postgres.image.pullPolicy="Always" \
     ./conjur
```

It may take a few minutes for the pods to come up in this installation.
You can use `kubectl get pods` to monitor the pods until the are up:

```shell
$ kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
conjur-conjur-oss-f689fc4db-cg7h4   2/2     Running   0          12m
conjur-postgres-6d5b59789c-hz5qv    1/1     Running   0          12m
$
```

#### View the app in the Google Cloud Console

Run the following commands until the `EXTERNAL-IP` column resolves:

```shell
INGRESS_SVC=$(kubectl get svc --no-headers -o custom-columns=":metadata.name" | grep conjur-oss-ingress)
kubectl get svc $INGRESS_SVC
```

To get the Console URL for your app, run the following commands:

```shell
EXT_IP=$(kubectl get svc "$INGRESS_SVC" -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "https://$EXT_IP"
```

To view the app, open the URL in your browser.

### Set up Conjur

To initialize Conjur, an account must be created. This is done by executing a command on a Conjur pod. This only needs to be done when launching a new Conjur application, or creating a new Conjur account.

```shell
# Find conjur pod and create a `default` account
$ export POD_NAME=$(kubectl get pods \
       -l "app=conjur-oss" \
       -o jsonpath="{.items[0].metadata.name}")
$ kubectl exec $POD_NAME --container=conjur-oss conjurctl account create default
Token-Signing Public Key: -----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA06mdosQTY76NLQTrgr7v
jkNLZC/a9jiKgeRTSJkMf+nJBLOVGmGgSZeU+eqDs/1Ldz/XJLouRk6XbSR8kAAQ
FtZbXFQKyyrRAJg3jN9DbB930FfyuBHpI/dPZVmKbBqiL4P8pwW9oj5ACzBgB1ZF
yz5iDWbmNyvIaqoYvSKpB7PItISOSX7C88LtxDsPK+eMxQnlu2kEg++P7OG2SFSW
EpVAd8v13QOUTG8u7dJ8LRJDBt7cBMagGAxp+cTRxvIGp63joBbn8Ca9rhZBMaeT
i/cFSx2B05QepUEFTVIJtSyF6cLUnRiXnZXVk61aRNbWOTEK8dGvkIBFswXPAN8z
/QIDAQAB
-----END PUBLIC KEY-----
Created new account 'default'
API key for admin: 1ma6hxgt6fagm52qgtn344xd1v1b7qrgp571fsm1250z6r3aewb9t
$
```

> Note that the `conjurctl account create` command gives you the public key and admin API key for the account you created. Back them up in a safe location.


### Connect remote with the Conjur CLI

Fetch the external IP for the Conjur service:

```shell
INGRESS_SVC=$(kubectl get svc --no-headers -o custom-columns=":metadata.name" | grep conjur-oss-ingress)
export EXT_IP=$(kubectl get svc "$INGRESS_SVC" -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

Pull and run the latest [cyberark/conjur-cli:5 image](https://hub.docker.com/r/cyberark/conjur-cli/) to connect to Conjur:

```shell
docker pull cyberark/conjur-cli:5
docker run \
       --rm -it \
       --env EXT_IP \
       --env CERTIFICATE_CN \
       --entrypoint bash \
       cyberark/conjur-cli:5
```

> Note that when connecting to the Conjur server, you must use hostname that
matches one of the subject names that are contained in Conjur server's CA
certificate, or you will get errors trying to log in. You can use the
$CERTIFICATE_CN environment variable that you set earlier, since that has
been configured as the CA certificate's subject common name.

Set up a DNS A record to map the target hostname ($CERTIFICATE_CN) to the Conjur
service's external IP, or alternatively, create a mapping entry in /etc/hosts:

```shell
grep -q $CERTIFICATE_CN /etc/hosts && \
    sed -i "s/.*$CERTIFICATE_CN/$EXT_IP $CERTIFICATE_CN/" /etc/hosts || \
    echo "$EXT_IP $CERTIFICATE_CN" >> /etc/hosts
```

Connect to the Conjur server using the account that you just created and login
as user `admin`, using the admin API key returned earlier as a password:

```shell
$ conjur init -u https://$CERTIFICATE_CN -a default
$ conjur authn login -u admin
Please enter admin's password (it will not be echoed):
Logged in
```

Confirm that you are logged in as user `admin`:

```shell
$ conjur authn whoami
{"account":"default","username":"admin"}
```

### Next steps

- Go through the [Conjur Tutorials](https://www.conjur.org/tutorials/)
- View Conjur’s [API Documentation](https://www.conjur.org/api.html)

# Scaling

This is a single-instance version of Conjur.
It is not intended to be scaled up with the current configuration.

# Upgrade the Application

## Prepare the environment

If you are using a remote database, no changes are needed.

## Upgrade Conjur

If you haven't already, set your kubectl context to point to the namespace
in which your Conjur application is running:

```shell
kubectl config set-context --current --namespace=<CONJUR-APP-NAMESPACE>
```

Set the new image version in an environment variable:

```shell
export NEW_VERSION=1.6.1
export IMAGE_CONJUR="gcr.io/cloud-marketplace/cyberark/conjur-open-source:$NEW_VERSION"
```

Update the Deployment definition with the reference to the new image:

```shell
kubectl patch deployment conjur-conjur-oss \
  --type='json' \
  --patch="[{ \
      \"op\": \"replace\", \
      \"path\": \"/spec/template/spec/containers/0/image\", \
      \"value\":\"${IMAGE_CONJUR}\" \
    }]"
```

Monitor the process with:

```shell
kubectl get pods \
  -l "app=conjur-oss" \
  --output go-template='Status={{.status.phase}} Image={{(index .spec.containers 0).image}}' \
  --watch
```

The Pod is terminated, and recreated with a new image for the `conjur`
container. After the update is complete, the final state of
the Pod is `Running`, and marked as 1/1 in the `READY` column.

# Uninstall the Application

## Using the Google Cloud Platform Console

1. In the GCP Console, open [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

1. From the list of applications, click **Conjur by CyberArk**.

1. On the Application Details page, click **Delete**.

## Using the command line

Delete the application release using Helm:

```sh-session
# Find the release
$ helm list | grep conjur

conjur	conjur   	1       	2020-03-09 15:36:14.293351857 -0400 EDT	deployed	conjur-1.3.7

# Delete the release
$ helm delete conjur
release "conjur" uninstalled
```

## Contributing

We welcome contributions of all kinds to this repository. For instructions on
how to get started and descriptions of our development workflows, please see
our [contributing guide][contrib].

[contrib]: https://github.com/cyberark/conjur-google-cloud-marketplace/blob/master/CONTRIBUTING.md

## License

This repository is licensed under Apache License 2.0 - see
[`LICENSE`](LICENSE) for more details.
