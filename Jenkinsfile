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
        TAG = "jenkins-${env.BRANCH_NAME}"
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
        TAG = ReleaseVersion()
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
         * vulnerabilities for builds in the cyberark/conjur repository.
         */
        stage('Scan deployer image') {
          steps {
            scanAndReport("gcr.io/conjur-cloud-launcher-onboard/cyberark/deployer:${TAG}", "CRITICAL")
          }
        }
        stage('Scan tester image') {
          steps {
            scanAndReport("gcr.io/conjur-cloud-launcher-onboard/cyberark/tester:${TAG}", "HIGH")
          }
        }
        stage('Scan nginx image') {
          steps {
            scanAndReport("gcr.io/conjur-cloud-launcher-onboard/cyberark/nginx:${TAG}", "CRITICAL")
          }
        }
        stage('Scan postgres image') {
          steps {
            scanAndReport("gcr.io/conjur-cloud-launcher-onboard/cyberark/postgres:${TAG}", "CRITICAL")
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
