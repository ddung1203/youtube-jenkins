pipeline {

  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins-build: app-build
    some-label: "build-app-${BUILD_NUMBER}"
spec:
  containers:
  - name: kubectl
    image: gcr.io/cloud-builders/kubectl
    command:
    - cat
    tty: true
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
      - name: jenkins-docker-cfg
        mountPath: /kaniko/.docker
  volumes:
  - name: jenkins-docker-cfg
    projected:
      sources:
      - secret:
          name: regsecret
          items:
            - key: .dockerconfigjson
              path: config.json
"""
    }

  }
    

  stages {
    stage('Checkout') {
      steps {
        script {
          git branch: 'dev', url: 'https://github.com/ddung1203/youtube-jenkins.git', credentialsId: ''
          sh 'ls -al'
        }
      }
    }
    
    stage('build') {
      steps {
        container('kaniko') {
        sh '/kaniko/executor --context `pwd` \
           --destination ghcr.io/ddung1203/youtube-reloaded:${BUILD_NUMBER} \
           --insecure \
           --skip-tls-verify  \
           --cleanup \
           --dockerfile Dockerfile \
           --verbosity debug'
        }
      }
    }
    
    stage('deploy') {
      steps {
        script { 
          withKubeConfig([credentialsId: 'KUBECONFIG', serverUrl: 'https://kubernetes.default', namespace: 'youtube']) {
            container('kubectl') {
              sh "sed -i 's/youtube-reloaded:latest/youtube-reloaded:${BUILD_NUMBER}/g' k8s-manifest/youtube/youtube-deployment.yaml"
              sh 'kubectl apply -f k8s-manifest/youtube/youtube-deployment.yaml'
            }
          }
        }
      }
    }
  }
}