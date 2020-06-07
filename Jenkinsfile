
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
            echo "checkout"
            checkout scm

            echo "tag"
            tag[arch][version] = repository + imagePrefix + ':' + arch + '-' + version

            // Pull latest nowar image for any other version than itself
            if( version != 'nowar' ) {
                echo "pull nowar"
                sh [
                    'docker pull',
                    tag[arch]['nowar'],
                    '.'
                ].join(' ')
            }

            echo "build"
            sh [
                'docker build',
                '-f', dockerfile,
                '-t', tag[arch][version],
                '--build-arg=version=' + version
            ].join(' ')

            // Push only if required
            if( repository != '' ) {
                sh [
                    'docker push',
                     tag[arch][version]
                 ].join(' ')
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
                architecture -> sh [
                    'docker pull',
                    tag[architecture[1]][version]
                ].join(' ')
            } )

            architectures.each( {
                architecture -> sh [
                    'docker manifest annotate',
                    architecture[2],
                    multiImage,
                    tag[architecture[1]][version]
                ].join(' ')
            } )

            sh [
                'docker push',
                multiImage
            ].join(' ')
        }
    }
}

// First the nowar image as it's needed for all other builds

stage( 'Build nowar' ) {
    parallel buildVersion( 'common/Dockerfile', 'nowar' )
}
/*
stage( 'Multiarch nowar' ) {
    multiArch( 'nowar' )
}

// Now build each version on each architecture then multi-arch them at the end

def multi = [:]
version.each( {
    v -> stage( 'Jenkins ' + v ) {
        // Force copy else multiArch closure won't see this value
        def version = v
        multi['Jenkins ' + version] = { -> multiArch( version ) }
        parallel buildVersion( 'jenkins/Dockerfile', version )
    }
} )

stage( 'Multiarch Jenkins' ) {
    parallel multi
}
*/
