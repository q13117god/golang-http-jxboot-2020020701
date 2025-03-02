pipeline {
  agent {
    label "jenkins-go"
  }
  environment {
    ORG = 'q13117god'
    APP_NAME = 'golang-http-jxboot-2020020701'
    CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
    DOCKER_REGISTRY_ORG = 'q13117god'
  }
  stages {
    stage('CI Build and push snapshot') {
      when {
        branch 'PR-*'
      }
      environment {
        PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
        PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
        HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
      }
      steps {
        container('go') {
          dir('/home/jenkins/go/src/github.com/q13117god/golang-http-jxboot-2020020701') {
            checkout scm
            sh "make linux"
            sh "export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml"
            sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
          }
          dir('/home/jenkins/go/src/github.com/q13117god/golang-http-jxboot-2020020701/charts/preview') {
            sh "make preview"
            sh "jx preview --app $APP_NAME --dir ../.."
          }
        }
      }
    }
    stage('Build Release') {
      when {
        branch 'master'
      }
      steps {
        container('go') {
          dir('/home/jenkins/go/src/github.com/q13117god/golang-http-jxboot-2020020701') {
            checkout scm
          }

          dir('/home/jenkins/go/src/github.com/q13117god/golang-http-jxboot-2020020701/charts/golang-http-jxboot-2020020701') {
            // ensure we're not on a detached head
            sh "git checkout master"
            sh "git config --global credential.helper store"
            sh "jx step git credentials"
          }

          dir('/home/jenkins/go/src/github.com/q13117god/golang-http-jxboot-2020020701') {
            // so we can retrieve the version in later steps
            sh "echo \$(jx-release-version) > VERSION"
          }

          dir('/home/jenkins/go/src/github.com/q13117god/golang-http-jxboot-2020020701/charts/golang-http-jxboot-2020020701') {
            sh "jx step tag --version \$(cat VERSION)"
          }

          dir('/home/jenkins/go/src/github.com/q13117god/golang-http-jxboot-2020020701') {
            container('go') {
              sh "make build"
              sh "export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml"

              sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"
            }
          }
        }
      }
    }
    stage('Promote to Environments') {
      when {
        branch 'master'
      }
      steps {
        container('go') {
          dir('/home/jenkins/go/src/github.com/q13117god/golang-http-jxboot-2020020701/charts/golang-http-jxboot-2020020701') {
            sh "jx step changelog --version v\$(cat ../../VERSION)"

            // release the helm chart
            sh "jx step helm release"

            // promote through all 'Auto' promotion Environments
            sh "jx promote -b --all-auto --timeout 1h --version \$(cat ../../VERSION)"
          }
        }
      }
    }
  }
}
