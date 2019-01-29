# Development on project

## Consuming This Repository

1. Clone the repository:

    `$ git clone git@github.com:cyberark/conjur-google-cloud-marketplace.git`

2. Update the Google Cloud Launcher [submodules|git-submodules]:

    ```
    $ git submodule sync --recursive
    $ git submodule update --recursive --init --force
    ```

[git-submodules]: https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools

## Working with the Google Cloud Onboarding Project

The project URL is: https://console.cloud.google.com/home/dashboard?organizationId=854380395992&project=conjur-cloud-launcher-onboard

## Cluster Setup

0. Run the following command to create the Application CRD: `$ make crd/install`.

1. Create the namespace from `setenv.sh`: `kubectl create ns "$(whoami)"`

2. Run the following to create the app: `$ make app/install`.

3. Run the following to watch the app: `$ make app/watch`.

4. Once the app is ready, find the external IP for Conjur and open it in your browser
    to view Conjur's status page:

    ```sh-session
    $ kubectl get svc
    NAME       TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
    conjur     LoadBalancer   10.55.254.167   35.237.110.166   443:30360/TCP   1m

    $ open https://35.237.110.166
    ```

6. Run the following to uninstall the app: `$ make app/uninstall`.

## Pushing New Container Images

This is done automatically by Jenkins in the build pipeline.

## Testing

`./build.sh` will automatically test the application with the configured kubectl context.
It will launch the application in a custom namespace, test it, and then delete the namespace.
This step is also automatically done by the build pipeline.
