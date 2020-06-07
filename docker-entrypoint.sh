#!/bin/bash

# /opt/jenkins is available for the workspace work files
jenkinsHome=/opt/jenkins
if [ ! -d ${jenkinsHome} ]
then
    mkdir -p ${jenkinsHome}
    chown jenkins:jenkins ${jenkinsHome}
fi

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

# Write logs to log directory not the console
logDir=${jenkinsHome}/logs
if [ ! -d ${logDir} ]
then
    mkdir -p ${logDir}
    chown jenkins:jenkins ${logDir}
fi
sed -i "s|@@logDir@@|${logDir}|g" /opt/log.properties
JAVA_OPTS="$JAVA_OPTS -Djava.util.logging.config.file=/opt/log.properties"

# Disable dns log spam
# https://stackoverflow.com/questions/31740373/how-can-i-prevent-that-the-jenkins-log-gets-spammed-with-strange-messages
JAVA_OPTS="$JAVA_OPTS -Dhudson.DNSMultiCast.disabled=true -Dhudson.udp=-1"

exec java $JAVA_OPTS -jar /opt/jenkins.war $OPTS
