imageName = 'area51/jenkins'

node( 'Dev_AMD64_Amsterdam' ) {
  stage( 'Checkout' ) {
    checkout scm
  }

  stage( 'Prepare Build' ) {
    sh 'docker pull area51/docker-client:latest'
  }

  stage( 'Retrieve jenkins.war' ) {
    sh 'curl -sSl -o jenkins.war http://mirrors.jenkins-ci.org/war/latest/jenkins.war'
  }

  stage( 'Build Image' ) {
    sh 'docker build -t ' + imageName + ' .'
  }
}
