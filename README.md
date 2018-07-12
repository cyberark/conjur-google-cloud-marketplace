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

1. In the marketplace-k8s-app-tools, run the following command to create the Application CRD: `$ make crd/install -f crd.Makefile`

## Pushing a New Container Image
1. Install the gcloud SDK on your local machine: https://cloud.google.com/sdk/docs/
2. Configure your loacl Docker to use the gcloud command-line tool to authenticate requests to the Google Cloud Container Registry (based on these [instructions|docker-gcloud-auth]):

    `$ gcloud auth configure-docker`

3. Tag the image: `$ docker tag _image_name_ gcr.io/[PROJECT-ID]/image_name:tag`
    
    Example: `$ docker tag conjur-deployer gcr.io/conjur-cloud-launcher-onboard/conjur-deployer:latest`

4. Push the image: `$ docker push gcr.io/[PROJECT-ID]/_image_name_:tag`
    
    Example: `$ docker push gcr.io/conjur-cloud-launcher-onboard/conjur-deployer:latest`

[docker-gcloud-auth]: https://cloud.google.com/container-registry/docs/quickstart#add_the_image_to_product_name_short

## Updating the Conjur Deployer Container Image
From the repo root folder, run the following commands:

```
$ docker build . -t us.gcr.io/conjur-cloud-launcher-onboard/cyberark/conjur-deployer:latest -f Dockerfile.deployer
$ docker push us.gcr.io/conjur-cloud-launcher-onboard/cyberark/conjur-deployer:latest
```