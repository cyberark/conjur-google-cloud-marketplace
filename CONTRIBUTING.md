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
- A Kubernetes platform on which to deploy the application and test containers. For building and testing, this does not need to be a Google Kubernetes Engine (GKE) cluster.
- A Docker registry to which to push images. This can be either:
  - A Dockerhub registry, or...
  - Access to the `conjur-cloud-launcher-onboard` GCP project, which
    provides access to the `gcr.io/conjur-cloud-launcher-onboard`
    Google Cloud Registry (GCR). To test if you have access to this GCP
    project, try browsing to this location:
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

### Configure Docker Registry

If you are using your own registry, run the following:

```sh-session
cd conjur-google-cloud-marketplace  # Root dir of this repository
export REGISTRY=<your-docker-registry>
export FLAT_REGISTRY=true
```
The setting of `FLAT_REGISTRY=true` is required because Dockerhub
registries typically require images to be stored in a flat
registry namespace (as opposed to Google Cloud Registry,
where images are stored in project directories).

Otherwise, if you are using the Google Cloud Registry, run:

```sh-session
cd conjur-google-cloud-marketplace
export REGISTRY=gcr.io/conjur-cloud-launcher-onboard
```

### Build, Deploy, and Test the Application

#### Build, Deploy, and Leave the Application Running

Follow these steps if you would like to build and deploy the application
and leave it running (for manual verification).

1. Build and deploy the application with the `--persist` flag:

   ```sh-session
   ./build.sh --persist
   ```

2. Confirm that the application is running and test jobs have completed.

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

3. Test access to the application.

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
1. View the current published version, and determine a new version number:

   ```sh-session
   $ grep publishedVersion: schema.yaml
   publishedVersion: '1.4.0'
   $
   ```

   In the above example, version `1.4.1` would be an acceptable new
   version number.
1. Update tag references to the new version:

   ```sh-session
   export NEW_VERSION=1.4.1
   sed -i "s/TAG_VERSION=.*/TAG_VERSION=$NEW_VERSION/" README.md
   sed -i "s/publishedVersion: .*/publishedVersion: \'$NEW_VERSION\'/" schema.yaml
   sed -i "s/version: .*/version: \'$NEW_VERSION\'/" conjur/templates/application.yaml
   sed -i "s/TAG ?= .*/TAG ?= '$NEW_VERSION/" Makefile
   ```

1. In CHANGELOG.md, move all entries currently in the `UNRELEASED` section
   to a new section with a header similar to the following:

   ```sh-session
   ## [1.4.1](https://github.com/cyberark/conjur-google-cloud-launcher/releases/tag/v1.4.1) - 2020-03-18
   ```

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
   using e.g. `git tag -s v1.4.1`. Note this requires you to be able to sign
   releases. Consult the
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

### Check for Vulnerabilities in Images Pushed to GCR

In a browser, navigate to the following GCR locations, and click on
the `Vulnerabilies` button to check for vulnerabilies:

- https://gcr.io/conjur-cloud-launcher-onboard/cyberark:1.4.1
- https://gcr.io/conjur-cloud-launcher-onboard/cyberark/deployer:1.4.1
- https://gcr.io/conjur-cloud-launcher-onboard/cyberark/nginx:1.4.1
- https://gcr.io/conjur-cloud-launcher-onboard/cyberark/postgres:1.4.1
- https://gcr.io/conjur-cloud-launcher-onboard/cyberark/tester:1.4.1
- https://gcr.io/conjur-cloud-launcher-onboard/cyberark/deployer:1.4.1

### Use of "Release Tracks"

The Conjur Google Marketplace Application follows the recommended
practice of releasing software in *tracks*, as described in the
[Organizing your releases](https://cloud.google.com/marketplace/docs/partners/kubernetes-solutions/set-up-environment#organize-releases)
section of the Google Cloud Marketplace [Setting up your Google Cloud environment](https://cloud.google.com/marketplace/docs/partners/kubernetes-solutions/set-up-environment) documentation.

Each *track* is a series of patch semantic versions with backwards-compatible
updates. The *track* is represented by a minor semantic version. For example,
if the released *track* version is `1.4`, then versions `1.4.0`, `1.4.1`,
and so on are expected to be backwards-compatible with *track* version
`1.4`.

The *track* version is what Marketplace users would use to deploy the
Marketplace application. Basically, the *track* version that the user sees
is mapped to the latest published patch version of the application.

Publishing a new version will therefore involve tagging and pushing of:
- Tag/push for the latest release images using patch version (e.g. `1.4.1`)
- Tag/push for the latest release images using track version (e.g. `1.4`)

### Push a *Track* Version of the Images to the GCR Registry

Push a "Track" Version of the Images to the GCR Registry:

```sh-session
export NEW_VERSION=1.4.1
export TRACK_VERSION=1.4

docker tag gcr.io/conjur-cloud-launcher-onboard/cyberark:$NEW_VERSION gcr.io/conjur-cloud-launcher-onboard/cyberark:$TRACK_VERSION
docker tag gcr.io/conjur-cloud-launcher-onboard/cyberark/deployer:$NEW_VERSION gcr.io/conjur-cloud-launcher-onboard/cyberark/deployer:$TRACK_VERSION
docker tag gcr.io/conjur-cloud-launcher-onboard/cyberark/nginx:$NEW_VERSION gcr.io/conjur-cloud-launcher-onboard/cyberark/nginx:$TRACK_VERSION
docker tag gcr.io/conjur-cloud-launcher-onboard/cyberark/postgres:$NEW_VERSION gcr.io/conjur-cloud-launcher-onboard/cyberark/postgres:$TRACK_VERSION
docker tag gcr.io/conjur-cloud-launcher-onboard/cyberark/tester:$NEW_VERSION gcr.io/conjur-cloud-launcher-onboard/cyberark/tester:$TRACK_VERSION

docker push gcr.io/conjur-cloud-launcher-onboard/cyberark:$TRACK_VERSION
docker push gcr.io/conjur-cloud-launcher-onboard/cyberark/deployer:$TRACK_VERSION
docker push gcr.io/conjur-cloud-launcher-onboard/cyberark/nginx:$TRACK_VERSION
docker push gcr.io/conjur-cloud-launcher-onboard/cyberark/postgres:$TRACK_VERSION
docker push gcr.io/conjur-cloud-launcher-onboard/cyberark/tester:$TRACK_VERSION
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
   mpdev publish --deployer_image=gcr.io/YOUR-PUBLIC-PROJECT/COMPANY-IDENTIFIER/YOUR-APP/deployer:VERSION --gcs_repo=gs://YOUR-BUCKET/COMPANY-IDENTIFIER/YOUR-APP/TRACK
   ```

   For example:

   ```sh-session
   mpdev publish --deployer_image=gcr.io/conjur-cloud-launcher-onboard/cyberark/deployer:1.4.1 --gcs_repo=gs://artifacts.conjur-cloud-launcher-onboard.appspot.com/cyberark:1.4
   ```

   You should see a published URL in the output, for example:

   ```sh-session
   Version is available at gs://artifacts.conjur-cloud-launcher-onboard.appspot.com/cyberark:1.4/1.4.1.yaml
   ```

### Install and Test the Published Application from the Cloud Storage Bucket

1. Install the app using mpdev:

   The reference command is:

   ```sh-session
   mpdev install --version_meta_file=gs://YOUR-BUCKET/YOUR-COMPANY/YOUR-APP/TRACK/VERSION --parameters='{"name": "YOUR-APP-INSTANCE", "namespace": "YOUR-NAMESPACE" <APP-SPECIFIC-PARAMETERS> }'
   ```

   For example:

   ```sh-session
   mpdev install --version_meta_file=gs://artifacts.conjur-cloud-launcher-onboard.appspot.com/cyberark:1.4/1.4.1.yaml --parameters='{"name": "conjur-test", "namespace": "conjur-test", "conjur-oss.ssl.hostname": "conjurtest.myorg.com"}'
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

And then browse to the URL that is displayed. You should see a live status for the application.

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
