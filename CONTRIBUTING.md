# Contributing to the Conjur Google Cloud Marketplace Application

Thank you for your interest in the Conjur Google Cloud Marketplace Application. Before contributing, please take a moment to read and sign our [Contributor Agreement](https://github.com/cyberark/community/blob/master/documents/CyberArk_Open_Source_Contributor_Agreement.pdf).
This provides patent protection for all Secretless Broker users and allows CyberArk to enforce its license terms. Please email a signed copy to oss@cyberark.com.

For general contribution and community guidelines, please see the [CyberArk community repo](https://github.com/cyberark/community).

## Table of Contents

- [Prerequisites](#prerequisites)
- [Pull Request Workflow](#pull-request-workflow)
- [Building, Deploying, and Testing](#building-deploying-and-testing)
- [Releasing](#releasing)
- [Publishing to Google Marketplace](#publishing-to-google-marketplace)

## Prerequisites

### Prerequisites for Building and Testing

In order to contribute to the Conjur Google Marketplace Application, you
must be able to build and test the required component images. To do this,
you will need:

- A development host with Docker server running.
- A Kubernetes platform on which to deploy the application and test containers.
For building and testing, this does not need to be a Google Kubernetes Engine
(GKE) cluster.
- Access to a Google Cloud Registry (GCR) account. If you have access to the
`conjur-cloud-launcher-onboard` GCP project, then this will provide you with
access to the `gcr.io/conjur-cloud-launcher-onboard` GCR registry. To test
if you have access to this GCP project, try browsing to this location:
    https://console.cloud.google.com/home/dashboard?project=conjur-cloud-launcher-onboard

### Prerequisites for Publishing to Google Marketplace 

In order to publish images to the Goggle Marketplace, you will need both:

- Access to the `conjur-cloud-launcher-onboard` Google Cloud Platform (GCP) project
- Access to the `cyberark-public` GCP project

To confirm that you have access to these projects, try browsing to the following locations:

- https://console.cloud.google.com/home/dashboard?project=conjur-cloud-launcher-onboard
- https://console.cloud.google.com/home/dashboard?project=cyberark-public


## Pull Request Workflow

1. [Clone this repository](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository)

    ```sh-session
    git clone git@github:cyberark/conjur-google-cloud-marketplace
    ```

2. Update the Google Cloud Launcher [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules):

    ```sh-session
    git submodule sync --recursive
    git submodule update --recursive --init --force
    ```

3. Create a local development branch

    For example:

    ```sh-session
    git checkout -b my-cool-fix
    ```

4. Make local changes to your fork by editing files

5. Build and test the component Docker images as described below in [Building and Testing](#building-and-testing).

6. [Commit your changes](https://help.github.com/en/github/managing-files-in-a-repository/adding-a-file-to-a-repository-using-the-command-line)

    For example:

    ```sh-session
    git commit -a -m "Adds a cool fix"
    ```

7. [Push your local changes to the remote repository](https://help.github.com/en/github/using-git/pushing-commits-to-a-remote-repository)

    For example:

    ```sh-session
    git push origin my-cool-fix
    ```

8. [Create new Pull Request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork)

From here your pull request will be reviewed and once you've responded to all
feedback it will be merged into the project. Congratulations, you're a
contributor!

## Building, Deploying, and Testing

Once you have completed Steps 1-4 in the [Pull Request Workflow](#pull-request-workflow) section above, you are ready to build the Conjur Google Marketplace Application, and test it on a Kubernetes platform.

### Create Namespace for Testing (Optional)

If you would like the namespace in which the application will run to have
a convenient name, create a namespace e.g. as follows:

```sh-session
export NAMESPACE="$(whoami)"
kubectl create ns "$NAMESPACE"
kubectl config set-context --current --namespace="$NAMESPACE"
```
If you choose not to create a namespace as shown above, a namespace with
a random name (of the form "apptest-XXXXXX") will be created.

### Configure Google Cloud Registry

Set $REGISTRY to point to your Google Cloud Registry:

```sh-session
cd conjur-google-cloud-marketplace
export REGISTRY=gcr.io/conjur-cloud-launcher-onboard
```

### Build, Deploy, and Test the Application

#### Build, Deploy, and Leave the Application Running

Follow these steps if you would like to build and deploy the application
and leave it running (for manual verification).

1. Configure an Issuer Common Name (CN) to be used in Conjur CA certificates.
This can be used as a DNS fully qualified hostname for access to Conjur:

   ```sh-session
   export CERTIFICATE_CN="myconjur.myorg.com"
   ```

1. Build and deploy the application with the `--persist` flag:

   ```sh-session
   ./build.sh --persist
   ```

1. Confirm that the application is running and test jobs have completed.

   When the script completes, you should see:

   ```sh-session
   serviceaccount/conjur-conjur-oss-serviceaccount-name created
   clusterrole.rbac.authorization.k8s.io/dane:conjur:conjur-oss.serviceAccount.name-r0 created
   clusterrolebinding.rbac.authorization.k8s.io/dane:conjur:conjur-oss.serviceAccount.name-rb0 created
   serviceaccount/conjur-deployer-sa configured
   secret/conjur-deployer-config created
   job.batch/conjur-deployer created
   rolebinding.rbac.authorization.k8s.io/conjur-deployer-rb created
   Done!
   ```

   Confirm that testing jobs have completed:

   ```sh-session
   $ kubectl get pods
   NAME                                 READY   STATUS      RESTARTS   AGE
   conjur-conjur-oss-6bf5b44b97-hd5n8   2/2     Running     0          19m
   conjur-deployer-z9fqk                0/1     Completed   0          20m
   conjur-postgres-855c6876cc-cpljm     1/1     Running     0          19m
   conjur-test-pi6md                    0/1     Completed   0          18m
   conjur-tester                        0/1     Completed   0          18m
   $ 
   ```

1. Test access to the application.

   Get the Conjur service load balancer external IP. It may take a few
   minutes for the external IP to be assigned:

   ```sh-session
   $ kubectl get svc
   NAME                        TYPE           CLUSTER-IP   EXTERNAL-IP      PORT(S)         AGE
   conjur-conjur-oss           NodePort       10.0.11.66   <none>           443:30138/TCP   109s
   conjur-conjur-oss-ingress   LoadBalancer   10.0.5.195   35.237.172.100   443:31897/TCP   110s
   conjur-postgres             ClusterIP      10.0.5.69    <none>           5432/TCP        109s
   $
   ```

   In your browser, navigate to the external IP, e.g.:

   ```
   https://35.237.172.100
   ```

   You should see the following status:

   ```sh-session
   Your Conjur server is running!
   ```

1. Configure Conjur

   Create an initial `default` account. Refer to the Conjur configuration instructions
   [here](https://www.conjur.org/get-started/quick-start/oss-environment/#step-5).

   ```
   export POD_NAME=$(kubectl get pods \
          -l "app=conjur-oss" \
          -o jsonpath="{.items[0].metadata.name}")
   kubectl exec $POD_NAME --container=conjur-oss conjurctl account create default
   ```

   Note that the above commands give you the public key and admin API key for
   the account that was created. Back them up in a safe location.

1. Connect to Conjur

   Start a container with Conjur CLI and authenticate with Conjur as
   user `admin`:

   ```
   INGRESS_SVC=$(kubectl get svc --no-headers -o custom-columns=":metadata.name" | grep conjur-oss-ingress)
   export EXT_IP=$(kubectl get svc $INGRESS_SVC -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
   docker run --rm -it --env EXT_IP --env CERTIFICATE_CN --entrypoint bash cyberark/conjur-cli:5
   ```

   In the Conjur CLI container, set up an entry in `/etc/hosts` for the
   Conjur server. (Alternatively, you can configure a DNS A record mapping
   the hostname that you configured in $CERTIFICATE_CN to the Conjur's external IP address).

   ```
   grep -q ($CERTIFICATE_CN /etc/hosts && \
       sed -i "s/.*$CERTIFICATE_CN/$EXT_IP $CERTIFICATE_CN/" /etc/hosts) || \
       echo "$EXT_IP $CERTIFICATE_CN" >> /etc/hosts
   ```

   Confirm that an entry has been added for $CERTIFICATE_CN in /etc/hosts:

   ```sh-session
   $ grep $CERTIFICATE_CN /etc/hosts
   35.237.172.100 myconjur.myorg.com
   $
   ```

   Then connect with the Conjur server using the account just created:

   ```sh-session
   $ conjur init -u https://$CERTIFICATE_CN -a default

   SHA1 Fingerprint=D2:1D:5D:1B:AD:2A:94:28:4F:D9:22:7B:0D:2C:5C:00:01:23:45:67

   Please verify this certificate on the appliance using command:
                 openssl x509 -fingerprint -noout -in ~conjur/etc/ssl/conjur.pem

   Trust this certificate (yes/no): yes
   Wrote certificate to /root/conjur-default.pem
   Wrote configuration to /root/.conjurrc
   $
   ```

   And then authenticate as user `admin`, using the admin API key obtained
   in the previous section as a password:

   ```sh-session
   $ conjur authn login -u admin -p <API_KEY>
   Logged in
   $
   ```

   Finally, check that you are logged in as user `admin`:

   ```sh-session
   $ conjur authn whoami
   {"account":"default","username":"admin"}
   $
   ```

#### Build, Deploy, Run Smoke Tests, and (Automatic) Clean Up

Follow these steps if you would like to build and deploy the application
and run automated smoke tests.

1. Build and deploy the application:

   ```sh-session
   ./build.sh
   ```

1. Confirm that the smoke test has passed:

   In the build output, you should see a message similar to the following
   stream by:

   ```sh-session
   SMOKE_TEST Tester 'Pod/apptest-1vuqbp0l-tester' succeeded.
   ```

   At the end of the output, you may see some ephemeral error conditions, e.g.:

   ```sh-session
   119s        Warning   Unhealthy          pod/apptest-1vuqbp0l-conjur-oss-75dbcd4f7-6z4n6   Liveness probe failed: Get http://10.52.2.40:80/: dial tcp 10.52.2.40:80: connect: connection refused
   ```

   The last line of output should be:

   ```sh-session
   Done!
   ```

   The application pods and deployment/test jobs will have been deleted
   automatically at this point. If a namespace had been created dynamically
   by the build script, it will have been deleted as well.

### Deleting the Application

If the application had been left running (for example, if you followed
the steps in [Build, Deploy, and Leave the Application Running](#build-deploy-and-leave-the-application-running)),
then you can clean up by deleting the application:

```sh-session
kubectl delete application conjur
```

and optionally deleting the namespace:

```sh-session
kubectl delete $NAMESPACE
```

## Releasing

### Update the version and changelog

1. Create a new branch for the version bump.

1. Edit the `VERSION` file to find the current published version, and
   replace that version with a new version. For example, if the
   current published version is `1.6.0`, then  an acceptable new
   version would be `1.6.1`.

1. In CHANGELOG.md, move all entries currently in the `UNRELEASED` section to
   a new section that is prefaced with the new version in square brackets, e.g.:

   ```sh-session
   ## [x.y.z](https://github.com/cyberark/conjur-google-cloud-launcher/releases/tag/v1.6.1) - 2020-04-18
   ```

   Where `x.y.z` represents the new version.

1. Commit these changes - `Bump version to x.y.z` is an acceptable commit
   message - and open a PR for review. Your PR should include updates to
   `CHANGELOG.md`, and if there are any license updates, to `NOTICES.txt`.

### Automated Push of Images to Google Cloud Storage by Jenkins Pipeline

Note that when changes are merged into master via the steps above, the
`conjur-google-cloud-launcher` Jenkins pipeline will automatically tag and
push new versions of the Conjur Google Marketplace Application component
images.

### Add a git tag

1. Once your changes have been reviewed and merged into master, tag the version
   using e.g. `git tag -s vx.y.z`, where `x.y.z` represents the new version.
   Note this requires you to be able to sign releases. Consult the
   [github documentation on signing commits](https://help.github.com/articles/signing-commits-with-gpg/)
   on how to set this up. `vx.y.z` is an acceptable tag message.
1. Push the tag: `git push vx.y.z` (or `git push origin vx.y.z` if you are working
   from your local machine).

### Build a release

**Note:** Until the stable quality exercises have completed, the GitHub release
should be officially marked as a `pre-release` (eg "non-production ready")

Create a GitHub release from the tag, add a description by copying the
CHANGELOG entries from the version. The following artifacts should be
uploaded to the release:
- CHANGELOG.md
- NOTICES.txt
- LICENSE

## Publishing to Google Marketplace

Reference: https://cloud.google.com/marketplace/docs/partners/kubernetes-solutions/maintaining-solution

### Prerequisites for Publishing to Google Marketplace 

As decribed in the [Prerequisites for Publishing to Google Marketplace](#prerequisites-for-publishing-to-google-marketplace)
above, publishing images to the Google Marketplace will require:
- Access to the `conjur-cloud-launcher-onboard` Google Cloud Platform (GCP) project
- Access to the `cyberark-public` GCP project

### Use of "Release Tracks"

The Conjur Google Marketplace Application follows the recommended
practice of releasing software in *tracks*, as described in the
[Organizing your releases](https://cloud.google.com/marketplace/docs/partners/kubernetes-solutions/set-up-environment#organize-releases)
section of the Google Cloud Marketplace [Setting up your Google Cloud environment](https://cloud.google.com/marketplace/docs/partners/kubernetes-solutions/set-up-environment) documentation.

Each *track* is a series of patch semantic versions with backwards-compatible
updates. The *track* is represented by a minor semantic version. For example,
if the released *track* version is `1.6`, then versions `1.6.0`, `1.6.1`,
and so on are expected to be backwards-compatible with current *track* version
`1.6`.

The *track* version is what Marketplace users would use to deploy the
Marketplace application. Basically, the *track* version that the user sees
is mapped to the latest published patch version of the application.

Publishing a new version will therefore involve tagging and pushing of:
- Tag/push for the latest release images using patch version `x.y.z`
- Tag/push for the latest release images using track version `x.y`
where `x.y.z` and `x.y` represent the latest version and track version,
respectively.

### Push a *Track* Version of the Images to the GCR Registry

Push a "Track" Version of the Images to the GCR Registry:

```sh-session
export NEW_VERSION=x.y.z  # Replace x.y.z with new version
export TRACK_VERSION=x.y  # Replace x.y with track version

export CONJUR_REPO="gcr.io/conjur-cloud-launcher-onboard/cyberark"
docker tag $CONJUR_REPO:$NEW_VERSION $CONJUR_REPO:$TRACK_VERSION
docker tag $CONJUR_REPO/deployer:$NEW_VERSION $CONJUR_REPO/deployer:$TRACK_VERSION
docker tag $CONJUR_REPO/nginx:$NEW_VERSION $CONJUR_REPO/nginx:$TRACK_VERSION
docker tag $CONJUR_REPO/postgres:$NEW_VERSION $CONJUR_REPO/postgres:$TRACK_VERSION
docker tag $CONJUR_REPO/tester:$NEW_VERSION $CONJUR_REPO/tester:$TRACK_VERSION

docker push $CONJUR_REPO:$TRACK_VERSION
docker push $CONJUR_REPO/deployer:$TRACK_VERSION
docker push $CONJUR_REPO/nginx:$TRACK_VERSION
docker push $CONJUR_REPO/postgres:$TRACK_VERSION
docker push $CONJUR_REPO/tester:$TRACK_VERSION
```

### Install the `mpdev` (Marketplace Development Tool) Script

The Google Marketplace development container
(`gcr.io/cloud-marketplace-tools/k8s-dev`) bundles all of the libraries
needed for developing Marketplace applications. When the development container
runs, it needs access to `gcloud` and `kubeconfig` configurations on the host
in order to run `gcloud` and `kubectl` commands on a GKE cluster.

The `mpdev` script facilitates mounting of the `gcloud` and `kubeconfig`
configurations when the development container is run. The `mpdev` script
can be extracted from the development container and copied to a local
bin directory, providing a convenient way to run the tools in the
development container.

References:
- https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/blob/master/docs/building-deployer.md#using-the-mpdev-development-tools
- https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/blob/master/docs/mpdev-references.md

1. Install mpdev on your local host:

   ```sh-session
   BIN_FILE="$HOME/bin/mpdev"
   docker run \
      gcr.io/cloud-marketplace-tools/k8s/dev \
      cat /scripts/dev > "$BIN_FILE"
   chmod +x "$BIN_FILE"
   ```

2. Check your  environment:

   ```sh-session
   $ mpdev doctor

   Your gcloud default project: conjur-cloud-launcher-onboard

   You can set an environment variables to record the GCR URL:

   export REGISTRY=gcr.io/$(gcloud config get-value project | tr ':' '/')

   ====

   Everything looks good to go!!
   $
   ```

### Push to Cloud Storage Bucket for Testing Published Images

Reference: 
https://cloud.google.com/marketplace/docs/partners/kubernetes-solutions/maintaining-solution#managing_updates_for_your_application

1. Find the GS (Google Storage) Buckets for Cyberark:

   ```sh-session
   $ gsutil ls
   gs://artifacts.conjur-cloud-launcher-onboard.appspot.com/
   gs://us.artifacts.conjur-cloud-launcher-onboard.appspot.com /
   $
   ```

2. Publish to GS bucket:

   NOTE: mpdev publish is sensitive to white space between arguments; single spaces are needed.

   The command to publish to the GS bucket is:

   ```sh-session
   mpdev publish \
         --deployer_image=gcr.io/YOUR-PUBLIC-PROJECT/COMPANY-IDENTIFIER/deployer:VERSION \
         --gcs_repo=gs://YOUR-BUCKET/COMPANY-IDENTIFIER:TRACK
   ```

   For example (replace `x.y.z` and `x.y` with the new version and track
   version respectively):

   ```sh-session
   mpdev publish \
         --deployer_image=gcr.io/conjur-cloud-launcher-onboard/cyberark/deployer:x.y.z \
         --gcs_repo=gs://artifacts.conjur-cloud-launcher-onboard.appspot.com/cyberark:x.y
   ```

   You should see a published URL in the output, for example:

   ```sh-session
   Version is available at gs://artifacts.conjur-cloud-launcher-onboard.appspot.com/cyberark:x.y/x.y.z.yaml
   ```

   where `x.y.z` and `x.y` represent the new version and track version,
   respectively.

### Install and Test the Published Application from the Cloud Storage Bucket

1. Install the app using mpdev:

   The reference command is:

   ```sh-session
   mpdev install \
         --version_meta_file=gs://YOUR-BUCKET/YOUR-COMPANY/TRACK/VERSION \
         --parameters='{"name": "YOUR-APP-INSTANCE", "namespace": "YOUR-NAMESPACE" <APP-SPECIFIC-PARAMETERS> }'
   ```

   For example:

   ```sh-session
   mpdev install \
         --version_meta_file=gs://artifacts.conjur-cloud-launcher-onboard.appspot.com/cyberark:1.6/1.6.1.yaml \
         --parameters='{"name": "conjur-test", "namespace": "conjur-test", "conjur-oss.ssl.hostname": "conjurtest.myorg.com"}'
   ```

   You should see successful creation of app:

   ```sh-session
   $ kubectl get pods -n conjur-test
   NAME                                      READY   STATUS      RESTARTS   AGE
   conjur-test-conjur-oss-7cb867d6c8-5hgxp   2/2     Running     0          3m17s
   conjur-test-deployer-6bwz7                0/1     Completed   0          3m23s
   conjur-test-postgres-786f6cbdbb-hll97     1/1     Running     0          3m18s
   $
   ```

### Test GCP Access to the App:

Run the following:

   ```sh-session
   ZONE=$(gcloud config list | awk '/zone =/{print $3}')
   CLUSTER=$(kubectl config current-context | sed 's/_/ /g' | awk '{print $NF}')
   NAMESPACE=conjur-test
   APP_INSTANCE_NAME=conjur-test
   echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
   ```

And then browse to the URL that is displayed. You should see a live status
for the application.

### Delete the Application

Delete the application:

   ```sh-session
   kubectl delete application -n conjur-test conjur-test
   ```
and optionally delete the namespace:

   ```sh-session
   kubectl delete ns conjur-test
   ```

### Submit the New Version of the Application for Approval

When you are read to submit the new version of the Application for
approval to be published, fill out the online form as describe in the
[Updating an existing version](https://cloud.google.com/marketplace/docs/partners/kubernetes-solutions/maintaining-solution#updating_an_existing_version)
section of the Google Marketplace [Maintaining your App](https://cloud.google.com/marketplace/docs/partners/kubernetes-solutions/maintaining-solution)
document.

The direct link to our Google Partner portal is:
- https://console.cloud.google.com/partner/solutions?project=cyberark-public

Once the new version has been scanned and approved by Google, you should see the new
version available on Google Marketplace:
- https://console.cloud.google.com/marketplace/details/cyberark/conjur-open-source?filter=solution-type:k8s&walkthrough_tutorial_id=java_gae_quickstart
