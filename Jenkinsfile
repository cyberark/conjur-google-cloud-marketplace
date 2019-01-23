#!/usr/bin/env groovy

pipeline {
  agent { label 'executor-v2' }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }

  stages {
    stage('Fetch marketplace submodule') {
      steps {
        sh 'git submodule sync --recursive'
        sh 'git submodule update --recursive --init --force'
      }
    }

    stage('GKE build-test-verify-publish') {
      when {
        anyOf {
          branch 'master'
        }
      }
      steps {
        sh 'cd ci && summon ./gke_test'
      }
    }
  }

  post {
    always {
      cleanupAndNotify(currentBuild.currentResult)
    }
  }
}
