# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Updated the Google Marketplace schema we use to Version 2, which will soon be
[required for all apps](https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/blob/c3e25deb4b40500e7416f3126c216a0f6a90d461/docs/schema.md#overview).
[PR #30](https://github.com/cyberark/conjur-google-cloud-marketplace/pull/30)
- The version of Conjur OSS used by the Marketplace app is bumped to 1.6.0.
[PR #44](https://github.com/cyberark/conjur-google-cloud-marketplace/pull/44)
- The README.md is updated and more detailed instructions have been added.
[PR #44](https://github.com/cyberark/conjur-google-cloud-marketplace/pull/44)

### Fixed
- Project deployment tools are updated to enable deploying on Kubernetes v1.15+
[cyberark/conjur-google-cloud-marketplace#25](https://github.com/cyberark/conjur-google-cloud-marketplace/issues/25).
This includes upgrading the Google Marketplace Tools container image used by
the Deployer from 0.7.0 to 0.10.0 to enable adaptive Kubectl client binary
version selection, upgrading the version of Helm used by the deployer from
2.6.1 to 2.16.1 to address a
[Helm bug](https://github.com/helm/helm/issues/2998),
and fixing the deployment's `deploy-info` manifest annotations to use valid
JSON keys (i.e. with quotes).

### Security
- Versions of the `nginx` (v1.17) and `deployer_helm` (v0.10.1) containers
were updated to address security vulnerabilities.
[Trivy](https://github.com/aquasecurity/trivy) scanning was added to the
pipeline to ensure the maintainer team is alerted to new fixable
vulnerabilities early going forward.
[cyberark/conjur-google-cloud-marketplace#35](https://github.com/cyberark/conjur-google-cloud-marketplace/issues/35),
[cyberark/conjur-google-cloud-marketplace#33](https://github.com/cyberark/conjur-google-cloud-marketplace/issues/33),
[cyberark/conjur-google-cloud-marketplace#34](https://github.com/cyberark/conjur-google-cloud-marketplace/issues/34)

## [1.3.4](https://github.com/cyberark/conjur-google-cloud-launcher/releases/tag/v1.3.4) - 2019-01-08
### Changed
- Dependency on Conjur OSS helm chart updated to newest release

## [1.2.0](https://github.com/cyberark/conjur-google-cloud-launcher/releases/tag/v1.2.0) - 2018-12-06
### Changed
- Authenticators parameter was added to configuration UI. See [conjur-oss Helm chart configuration](https://github.com/cyberark/conjur-oss-helm-chart/tree/master/conjur-oss#configuration).

## [1.1.0](https://github.com/cyberark/conjur-google-cloud-launcher/releases/tag/v1.1.0) - 2018-08-10
### Changed
- Helm chart now comes from https://github.com/cyberark/conjur-oss-helm-chart
- Some variable names have changed, see [conjur-oss Helm chart configuration](https://github.com/cyberark/conjur-oss-helm-chart/tree/master/conjur-oss#configuration).

## [1.0.0](https://github.com/cyberark/conjur-google-cloud-launcher/releases/tag/v1.0.0) - 2018-07-16
### Added
- Initial release
