#!/usr/bin/env groovy

import groovy.transform.Field

@Field
def TAG = ""

pipeline {
  agent { label 'executor-v2' }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }

  triggers {
    cron(getDailyCronString())
  }

  environment {
    REGISTRY = 'gcr.io/conjur-cloud-launcher-onboard'
  }

  stages {
    stage('Fetch marketplace submodule') {
      steps {
        sh 'git submodule sync --recursive'
        sh 'git submodule update --recursive --init --force'
      }
    }

    stage('GKE build-test-verify') {
      when {
        not {
          branch 'master'
        }
      }

      environment {
        TAG = sh(returnStdout: true, script: 'echo $(< VERSION)-$(git rev-parse --short HEAD) | tr -d "\n"')
      }

      steps {
        sh 'cd ci && summon ./jenkins_build'
        script {
          TAG = "${env.TAG}"
        }
      }
    }

    stage('GKE build-test-verify-publish') {
      when {
        anyOf {
          branch 'master'
        }
      }

      environment {
        TAG = sh(returnStdout: true, script: 'echo $(< VERSION) | tr -d "\n"')
      }

      steps {
        sh 'cd ci && summon ./jenkins_build'
        script {
          TAG = "${env.TAG}"
        }
      }
    }

    stage('Scan images for vulnerabilities') {
      parallel {
        /*
         * A scan of the conjur image is skipped since this image is scanned
         * vulnerabilities for builds in the cyberark/conjur repository and we
         * make no changes to the container here.
         *
         * `false` in the 3rd parameter to scanAndReport means to ignore issues
         * with no fix. `true` means to include those issues in the report.
         */
        stage('Scan deployer image for fixable issues') {
          steps {
            scanAndReport("gcr.io/conjur-cloud-launcher-onboard/cyberark/deployer:${TAG}", "HIGH", false)
          }
        }
        stage('Scan deployer image for all issues') {
          steps {
            scanAndReport("gcr.io/conjur-cloud-launcher-onboard/cyberark/deployer:${TAG}", "NONE", true)
          }
        }
        stage('Scan tester image for fixable issues') {
          steps {
            scanAndReport("gcr.io/conjur-cloud-launcher-onboard/cyberark/tester:${TAG}", "HIGH", false)
          }
        }
        stage('Scan tester image for all issues') {
          steps {
            scanAndReport("gcr.io/conjur-cloud-launcher-onboard/cyberark/tester:${TAG}", "NONE", true)
          }
        }
        stage('Scan nginx image for fixable issues') {
          steps {
            scanAndReport("gcr.io/conjur-cloud-launcher-onboard/cyberark/nginx:${TAG}", "HIGH", false)
          }
        }
        stage('Scan nginx image for all issues') {
          steps {
            scanAndReport("gcr.io/conjur-cloud-launcher-onboard/cyberark/nginx:${TAG}", "NONE", true)
          }
        }
        stage('Scan postgres image for fixable issues') {
          steps {
            scanAndReport("gcr.io/conjur-cloud-launcher-onboard/cyberark/postgres:${TAG}", "HIGH", false)
          }
        }
        
        stage('Scan postgres image for all issues') {
          steps {
            scanAndReport("gcr.io/conjur-cloud-launcher-onboard/cyberark/postgres:${TAG}", "NONE", true)
          }
        }
      }
    }
  }

  post {
    always {
      cleanupAndNotify(currentBuild.currentResult)
    }
  }
}

def ReleaseVersion() {
  application = readYaml file: 'conjur/templates/application.yaml'
  return application.spec.descriptor.version
}
