#!/bin/ash
#
# Environment variables:
# MAVEN_MIRROR          The url of a local repository to use instead of maven central
# MAVEN_PRIVATE_MIRROR  Optional when MAVEN_MIRROR is in use, a secondary mirror
#
# JNLP Slave:
# ===========
# JENKINS_URL           Url to the Jenkins server
# JENKINS_SECRET        Secret key
#
# SSH Slave:
# ==========
# JENKINS_PASSWORD      Optional, the password for the Jenkins user
#

. /config-jenkins.sh
. /config-docker.sh
. /config-maven.sh
. /config-ssh.sh

/usr/sbin/sshd -D -f /etc/ssh/sshd_config &

OPTS="--webroot=/opt/war"

if [ -n "$JENKINS_PREFIX" ]
then
    OPTS="$OPTS --prefix=$JENKINS_PREFIX"
fi

if [ -n "$JENKINS_PORT" ]
then
    OPTS="$OPTS --httpPort=$JENKINS_PORT"
fi

if [ -n "$JENKINS_PREFIX" ]
then
    OPTS="$OPTS --prefix=$JENKINS_PREFIX"
fi

if [ -n "$JENKINS_OPTS" ]
then
    OPTS="$OPTS $JENKINS_OPTS"
fi

exec /opt/jdk/bin/java $JAVA_OPTS -jar /opt/jenkins.war $OPTS
