
properties( [
  buildDiscarder(
    logRotator(
      artifactDaysToKeepStr: '',
      artifactNumToKeepStr: '',
      daysToKeepStr: '7',
      numToKeepStr: '10'
    )
  ),
  disableConcurrentBuilds(),
  disableResume(),
  pipelineTriggers([
    cron('H H * * 1')
  ])
])

// Repository name use, must end with / or be '' for none.
// Setting this to '' will also disable any pushing
repository= 'area51/'

// image prefix
imagePrefix = 'jenkins'

// The architectures to build. This is an array of [node,arch]
architectures = [
 ['AMD64', 'amd64'],
 ['ARM64', 'arm64v8'],
 ['ARM32v7', 'arm32v7']
]

// The image tag (i.e. repository/image but no version)
imageTag=repository + imagePrefix

// The image version based on the branch name - master branch is latest in docker
version=BRANCH_NAME
if( version == 'master' ) {
  version = 'latest'
}

// Final image name
def multiImage  = repository + imagePrefix + ':' + version,
    tag         =[:],   // tag name keyed by architecture
    build       = [:],  // build steps keyed by architecture
    imageTags   = '',   // list of image tags space separated
    images      = [:]   // map of annotate commands keyed by image name

for( architecture in architectures ) {
    // Need to bind these before the closure, cannot access these as architecture[x]
    def nodeId = architecture[0]
    def arch = architecture[1]

    // The docker image name for this architecture
    tag[arch] = repository + imagePrefix + ':' + arch + '-' + version

    // Append to the list
    imageTags = imageTags + ' ' + tag[arch]

    // The build step for the architecture
    build[arch] = {
        node( nodeId ) {
            stage( arch ) {
                checkout scm

                sh 'curl -sSL -o jenkins.war http://mirrors.jenkins-ci.org/war/latest/jenkins.war'

                sh 'docker build -t ' + tag[arch] + ' .'

                // Push only if required
                if( repository != '' ) {
                    sh 'docker push ' + tag[arch]
                }
            }
        }
    }

    // The annotation command
    def cmd = 'docker manifest annotate --os linux '
    switch( arch ) {
        case 'arm32v6':
            cmd = cmd + '--arch arm --variant v6'
            break
        case 'arm32v7':
            cmd = cmd + '--arch arm --variant v7'
            break
        case 'arm64v8':
            cmd = cmd + '--arch arm64'
        default:
            cmd = cmd + '--arch ' + arch
    }
    images[tag[arch]] = cmd + ' ' + multiImage + ' ' + tag[arch]
}

// Now run the builds for all architectures in parallel
stage( 'Build' ) {
    parallel build
}

// Now the multiarch image, run this on one node only
node( 'AMD64' ) {
    stage( "Multiarch" ) {
        // Create the new image manifest with the child image layers attached
        sh 'docker manifest create -a ' + multiImage + imageTags

        for( image in images ) {
            // Pull the image
            sh 'docker pull ' + image[0]
            // Annotate it to the correct architecture
            sh image[1]
        }

        // Push the final multiarch image
        sh 'docker manifest push -p ' + multiImage
    }
}
