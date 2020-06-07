# Docker file common to all of our Jenkins containers.
# This is the nowar version which contains the JDK, base utilities & the jenkins user

FROM adoptopenjdk/openjdk11:debian-slim AS jdk
MAINTAINER Peter Mount <peter@area51.dev>

# Add the common source control apps
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
            curl \
            git \
            mercurial \
            subversion &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Now add the jenkins user & startup script
FROM jdk AS jenkins
ARG gid=1000
ARG uid=1000

ENV JENKINS_HOME /opt/jenkins
ENV JENKINS_PORT 80

RUN mkdir -p ${JENKINS_HOME} &&\
    chown ${uid}:${gid} -R ${JENKINS_HOME} &&\
    addgroup --gid ${gid} jenkins &&\
    adduser --system \
            --home ${JENKINS_HOME} \
	        --shell /bin/bash \
    	    --uid ${uid} \
	        --gid ${gid} \
	        --disabled-login \
	        jenkins

# Now run as the jenkins user
USER jenkins
