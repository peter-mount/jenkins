imageName = 'area51/jenkins'

properties( [
  buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '7', numToKeepStr: '10')),
  disableConcurrentBuilds(),
  disableResume(),
  pipelineTriggers([
    upstream('/Public/Docker-Client/master'),
    cron('H H * * 1')
  ])
])

node( 'AMD64' ) {
  stage( 'Checkout' ) {
    checkout scm
  }

  stage( 'Prepare Build' ) {
    sh 'docker pull area51/docker-client:latest'
  }

  stage( 'Retrieve jenkins.war' ) {
    sh 'curl -sSL -o jenkins.war http://mirrors.jenkins-ci.org/war/latest/jenkins.war'
  }

  stage( 'Build Image' ) {
    sh 'docker build -t ' + imageName + ' .'
  }

  stage( 'Publish Image' ) {
    sh 'docker push ' + imageName
  }
}
