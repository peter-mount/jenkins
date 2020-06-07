
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

// The architectures to build. This is an array of [label,arch]
architectures = [
 ['AMD64', 'amd64'],
 ['ARM64', 'arm64v8'],
 ['ARM32v7', 'arm32v7']
]

// The jenkins versions to build, always latest and the LTD version & select other versions to allow a
// rollback if latest breaks for any reason
//
// nowar    Special case, image only has the jenkins user setup, no war or entry point configured
// latest   the current latest war
// lts      the current lts war
versions = [ 'nowar', 'latest', "lts", "2.238" ]

// ============================
// Do not edit below this point
// ============================

// For jenkins instead of using the branch we use an array of supported version
// numbers so we build a set of images for each version on all architectures

// Final image name
def tag         =[:],   // tag name keyed by architecture
    build       = [:],  // build steps keyed by architecture
    imageTags   = '',   // list of image tags space separated
    images      = [:]   // map of annotate commands keyed by image name

for( architecture in architectures ) {
    // Need to bind these before the closure, cannot access these as architecture[x]
    def nodeId = architecture[0]
    def arch = architecture[1]

    // The docker image name for this architecture
    tag[arch] = [:]
    for( version in versions ) {
        tag[arch][version] = repository + imagePrefix + ':' + arch + '-' + version
    }

    // The build step for the architecture
    build[arch] = {
        node( nodeId ) {
            stage( arch ) {
                checkout scm

                //sh 'curl -sSL -o jenkins.war http://mirrors.jenkins-ci.org/war/latest/jenkins.war'

                for( version in versions ) {
                    def cmd = 'docker build -t ' + tag[arch][version]
                    cmd = cmd + ' --build-arg=version=' + version
                    if( version == 'nowar' ) {
                        cmd = cmd + ' --target=jenkins'
                    } else {
                        cmd = cmd + ' --target=war'
                    }
                    sh cmd + ' .'
                }

                // Push only if required
                if( repository != '' ) {
                    for( version in versions ) {
                        sh 'docker push ' + tag[arch][version]
                    }
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
    images[arch] = [:]
    for( version in versions ) {
        def multiImage  = repository + imagePrefix + ':' + version
        images[arch][version] = cmd + ' ' + multiImage + ' ' + tag[arch][version]
    }
}

// Now run the builds for all architectures in parallel
stage( 'Build' ) {
    parallel build
}

// Now the multi-arch image, run this on one node only
node( 'AMD64' ) {
    for( version in versions ) {
        stage( "Multi-" + version ) {
            def multiImage  = repository + imagePrefix + ':' + version

            // Create the new image manifest with the child image layers attached
            def cmds = [ 'docker manifest create -a ' + multiImage ]

            for( architecture in architectures ) {
                for( image in images[architecture] ) {
                    // Append image name to manifest create command
                    cmds[0] = cmds[0] + ' ' + image[0]
                    // Pull the image
                    cmds << 'docker pull ' + image[0]
                    // Annotate it to the correct architecture
                    cmds << image[1]
                }
            }

            // Push the image
            cmds << 'docker manifest push -p ' + multiImage

            // Run the command sequence
            for( cmd in cmds ) {
                sh cmd
            }
        }
    }
}
