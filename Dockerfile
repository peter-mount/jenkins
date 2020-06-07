# Docker file to build the jenkins container used by the Area51 project

FROM adoptopenjdk/openjdk8:debian-slim AS jdk
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

# Startup script & logging template
COPY docker-entrypoint.sh /
COPY log.properties /

RUN chmod 500 /docker-entrypoint.sh &&\
    mkdir -p ${JENKINS_HOME} &&\
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

ENTRYPOINT  ["/docker-entrypoint.sh"]

# Final image with just the war added to /opt
# Having this as a separate build step will allow us to generate versioned
# builds with the same base image & just 1 layer being different - i.e.
# older known-good jenkins versions with just the JDK updated
FROM jenkins

COPY jenkins.war /opt/jenkins.war
