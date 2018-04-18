imageName = 'area51/jenkins'

properties( [
  buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '7', numToKeepStr: '10')),
  disableConcurrentBuilds(),
  disableResume(),
  pipelineTriggers([
    upstream('/peter-mount/docker-client/master'),
    cron('H H * * 1')
  ])
])

node( 'AMD64' ) {
  stage( 'Prepare' ) {
    checkout scm
    sh 'docker pull area51/docker-client:latest'
  }

  stage( 'Retrieve jenkins.war' ) {
    sh 'curl -sSL -o jenkins.war http://mirrors.jenkins-ci.org/war/latest/jenkins.war'
  }

  stage( 'Build' ) {
    sh 'docker build -t ' + imageName + ' .'
  }

  stage( 'Publish' ) {
    sh 'docker push ' + imageName
  }
}
