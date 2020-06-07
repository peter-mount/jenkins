
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
// Also agent is custom and independent of this
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
def tag = architectures.inject( [:] ) {
    a, b -> L:{
        a[b[1]] = [:]
        return a
    }
}

// Build a specific image on a specific architecture
def buildImage = {
    dockerfile, arch, version -> node( arch ) {
        stage( arch ) {
            tag[arch][version] = repository + imagePrefix + ':' + arch + '-' + version
            echo "Docker image " + tag[arch][version]

            checkout scm

            // Pull latest nowar image for any other version than itself
            if( version == 'nowar' ) {
                sh 'docker build -f ' + dockerfile + ' -t ' + tag[arch][version] + ' .'
            } else {
                sh 'docker pull ' +tag[arch]['nowar']
                sh 'docker build -f ' + dockerfile + ' -t ' + tag[arch][version] + ' --build-arg version=' + version + ' .'
            }

            // Push only if required
            if( repository != '' ) {
                sh 'docker push ' + tag[arch][version]
            }
        }
    }
}

// Returns an object for building a version on all architectures
def buildVersion = {
    dockerfile, version -> architectures.inject( [:] ) {
        a, b -> L:{
            // Ensure we have a copy of the value else closure breaks
            def label = b[0], arch = b[1]
            a[label] = { -> buildImage( dockerfile, arch, version ) }
            return a
        }
    }
}

// Builds a multiarch image for a specific version
def multiArch = {
    version -> node( 'AMD64' ) {
        stage( version ) {
            def multiImage  = repository + imagePrefix + ':' + version

            def manifest = architectures.inject( [
                'docker manifest create',
                '-a', multiImage
            ] ) {
                a, arch -> L:{
                    a << repository + imagePrefix + ':' + arch[1] + '-' + version
                    return a
                }
            }
            sh manifest.join(' ')

            architectures.each( {
                architecture -> L:{
                    sh 'docker pull ' + tag[architecture[1]][version]
                    sh 'docker manifest annotate ' + architecture[2] + ' ' + multiImage + ' ' + tag[architecture[1]][version]
                }
            } )

            sh 'docker manifest push -p ' + multiImage
        }
    }
}

// First the nowar image as it's needed for all other builds
stage( 'nowar' ) {
    parallel buildVersion( 'common/Dockerfile', 'nowar' )
}
// This is the only image that we must multiArch now
multiArch( 'nowar' )

// Holds the multiArch images to build at the end
def multi = [:]

// Now the agent, this uses it's own Dockerfile as not a jenkins master
// but a docker slave
stage( 'agent' ) {
    parallel buildVersion( 'agent/Dockerfile', 'agent' )
}
multi['agent'] = { -> multiArch( 'agent' ) }

// Now build each version of jenkins on each architecture
versions.each( {
    v -> stage( v ) {
        // Force copy else multiArch closure won't see this value
        def version = v
        multi[version] = { -> multiArch( version ) }
        parallel buildVersion( 'jenkins/Dockerfile', version )
    }
} )

// Finally build the multiarch images
stage( 'multiArch' ) {
    parallel multi
}
