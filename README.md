# conjur-google-cloud-launcher
Conjur application for Google Cloud Launcher

# Development

## Consuming This Repository

1. Clone the repository:

    `$ git clone _this_repo_address_`

2. Update the Google Cloud Launcher [submodules|git-submodules]:

    ```
    $ git submodule sync --recursive
    $ git submodule update --recursive --init --force
    ```

[git-submodules]: https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools

## Working with the Google Cloud Onboarding Project

The project URL is: https://console.cloud.google.com/home/dashboard?organizationId=854380395992&project=conjur-cloud-launcher-onboard
    
## Cluster Setup

0. Set environment variables with `source setenv.sh`.

1. Run the following command to create the Application CRD: `$ make crd/install`.

2. Run the following to create the app: `$ make app/install`.

3. Run the following to watch the app: `$ make app/watch`.

4. Run the following to uninstall the app: `$ make app/uninstall`.

## Pushing a New Container Image
1. Install the gcloud SDK on your local machine: https://cloud.google.com/sdk/docs/
2. Configure your loacl Docker to use the gcloud command-line tool to authenticate requests to the Google Cloud Container Registry (based on these [instructions|docker-gcloud-auth]):

    `$ gcloud auth configure-docker`

3. Tag and push the imge: `$ make clean; make .build/conjur/conjur

[docker-gcloud-auth]: https://cloud.google.com/container-registry/docs/quickstart#add_the_image_to_product_name_short

## Updating the Conjur Deployer Container Image
From the repo root folder, run the following commands:

```sh-session
$ make clean; make .build/conjur/conjur
```