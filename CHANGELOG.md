# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Upgraded the Google Marketplace Tools container image used by the Deployer from 0.7.0 to 0.10.0. The newer version of these tools provide an adaptive Kubectl client version (tools read the Kubernetes server version, then select a matching kubectl binary).
- Upgraded the Google Marketplace Tools submodule to 0.10.0.
- Upgraded the version of Helm used by the deployer from 2.6.1 to 2.16.1 to eliminate this Helm bug: https://github.com/helm/helm/issues/2998
- Deleted x-google-marketplace section for tester.image in schema.yaml to be consistent for Google Marketplace Tools v0.10.0
- Added a build.sh flag (`-p` or `--persist`) to persist the application deployment after testing.
- Fixed the deployment's `deploy-info` annotations to use keys that are valid JSON keys (i.e. with quotes).
- Updates the Google Marketplace schema we use to Version 2.

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
