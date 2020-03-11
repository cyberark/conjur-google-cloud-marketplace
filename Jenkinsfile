#!/usr/bin/env groovy

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
