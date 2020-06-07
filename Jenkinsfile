
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

// The architectures to build. This is an array of [label,arch, annotation]
architectures = [
 ['AMD64',      'amd64',    '--os linux --arch amd64'],
 ['ARM64',      'arm64v8',  '--os linux --arch arm64'],
 ['ARM32v7',    'arm32v7',  '--os linux --arch arm --variant v7']
]

// The jenkins versions to build, always latest and the LTD version & select other versions to allow a
// rollback if latest breaks for any reason.
//
// Note: The nowar version is always built first so no need to include it here.
//
// latest is always the current latest war, lts the current lts war
//
versions = [ 'latest', "lts", "2.238" ]

// ============================
// Do not edit below this point
// ============================

// For jenkins instead of using the branch we use an array of supported version
// numbers so we build a set of images for each version on all architectures

// map of image names. Always tag[arch][version]
def tag = [:]

// Build a specific image on a specific architecture
def buildImage = {
    dockerfile, arch, version -> {
        node( arch ) {
            stage( arch ) {
                checkout scm

                tag[arch][version] = repository + imagePrefix + ':' + arch + '-' + version

                // Pull latest nowar image for any other version than itself
                if( version != 'nowar' ) {
                    sh 'docker pull ' + tag[arch]['nowar']
                }

                sh 'docker build -f ' + dockerfile + ' -t ' + tag[arch][version] + ' --build-arg=version=' + version

                // Push only if required
                if( repository != '' ) {
                    sh 'docker push ' + tag[arch][version]
                }
            }
        }
    }
}

// Returns an object for building a version on all architectures
def buildVersion = {
    dockerfile, version -> architectures.reduce(
            a, b -> {
                // Ensure we have a copy of the value else closure breaks
                def label = b[0], arch = b[1]
                a[label] = () -> buildImage( dockerfile, arch, version )
                return a
            },
            [:]
        )
}

// Builds a multiarch image for a specific version
def multiArch = {
    version -> {
        node( 'AMD64' ) {
            stage( version ) {
                def multiImage  = repository + imagePrefix + ':' + version

                sh architectures.map( a -> a[1] )
                    .reduce( a, arch -> {
                        a << repository + imagePrefix + ':' + arch + '-' + version
                        return a
                    },
                    [
                      'docker manifest create -a',
                       multiImage
                    ] )

                sh [
                    'docker manifest create -a',
                     multiImage,
                     images.join(' ')
                 ].join(' ')

                architectures.each(
                    architecture -> sh [
                        'docker pull',
                        tag[architecture[1]][version]
                    ].join(' ')
                )

                architectures.each(
                    architecture -> sh [
                        'docker manifest annotate',
                        architecture[2],
                        multiImage,
                        tag[architecture[1]][version]
                    ].join(' ')
                )

                sh ['docker push',multiImage].join(' ')
            }
        }
    }
}

// First the nowar image as it's needed for all other builds
stage( 'Build nowar' ) {
    parallel buildVersion( 'common/Dockerfile', 'nowar' )
}
stage( 'Multiarch nowar' ) {
    multiArch( 'nowar' )
}

// Now build each version on each architecture then multi-arch them at the end
def multi = [:]
version.each( v -> {
    // Force copy else multiArch closure won't see this value
    def version = v
    stage( 'Jenkins ' + version ) {
        parallel buildVersion( 'jenkins/Dockerfile', version )
    }
    multi['Jenkins ' + version] = () -> multiArch( version )
}
stage( 'Multiarch Jenkins' ) {
    parallel multi
}
