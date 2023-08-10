pipeline {
  agent any

  environment {
    githubCredential='GitHub_Access_Token'
    gitURL='https://github.com/ddung1203/youtube-reloaded.git'
    gitEmail='jeonjungseok1203@gmail.com'
    gitName='Joongseok Jeon'
    dockerURL='ddung1203/youtube'
  }

  stages {
    stage('Checkout Application Git Branch') {
      steps {
        checkout([$class: 'GitSCM', branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[credentialsId: githubCredential, url: 'gitURL']]])
      }
      post {
        failure {
          echo 'Repository Clone Failure'
          slackSend (color: '#FF0000', message: "FAILED: Repository Clone Failure")
        }
        success {
          echo 'Repository Clone Success'
          slackSend (color: '#0AC9FF', message: "SUCCESS: Repository Clone Success")
        }
      }
    }

    stage('Docker Image Build') {
      steps{
        sh "docker build -t ${dockerURL}:${env.BUILD_NUMBER} ."
      }
      post {
        success {
          echo "The Docker Image Build stage successfully."
          slackSend (color: '#0AC9FF', message: "SUCCESS: Docker Image Build SUCCESS")
        }
        failure {
          echo "The Docker Image Build stage failed."
          slackSend (color: '#FF0000', message: "FAILED: Docker Image Build FAILED")
        }
      }
    }

    stage('Docker Image Upload'){
      steps {
        sh "docker push ${dockerURL}:${env.BUILD_NUMBER}"
      }
      post {
        success {
          echo "The deploy stage successfully."
          slackSend (color: '#0AC9FF', message: "SUCCESS: Docker Image Upload SUCCESS")
        }
        failure {
          echo "The deploy stage failed."
          slackSend (color: '#FF0000', message: "FAILED: Docker Image Upload FAILED")
        }
      }
    }

    stage('Kubernetes Manifest Update') {
      steps {
        git credentialsId: githubCredential,
            url: 'gitURL',
            branch: 'master'

        // 이미지 태그 변경 후 메인 브랜치에 push
        sh "git config --global user.email ${gitEmail}"
        sh "git config --global user.name ${gitName}"
        sh "sed -i 's/${dockerURL}:.*/${dockerURL}:${env.BUILD_NUMBER}/g' helm-charts/youtube/values.yaml"
        sh "git add ."
        sh "git commit -m 'fix:${dockerURL} ${env.BUILD_NUMBER} image versioning'"
        sh "git branch -M master"
        sh "git remote remove origin"
        sh "git remote add origin ${gitURL}"
        sh "git checkout master"
        sh "git push -u origin master"
      }
      post {
        failure {
          echo 'Kubernetes Manifest Update failure'
          slackSend (color: '#FF0000', message: "FAILED: Kubernetes Manifest Update '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        }
        success {
          echo 'Kubernetes Manifest Update success'
          slackSend (color: '#0AC9FF', message: "SUCCESS: Kubernetes Manifest Update '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        }
      }
    }
  }
}