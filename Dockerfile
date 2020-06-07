# Docker file to build the jenkins container used by the Area51 project

FROM adoptopenjdk/openjdk8:debian-slim AS jdk
MAINTAINER Peter Mount <peter@area51.dev>

# Add the common source control apps
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
        git \
        mercurial \
        subversion &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Now add the jenkins user & startup script
FROM jdk AS jenkins

ENV JENKINS_HOME /opt/jenkins
ENV JENKINS_PORT 80

# Startup script & logging template
COPY docker-entrypoint.sh /
COPY log.properties /

RUN chmod 500 /docker-entrypoint.sh &&\
    mkdir ${JENKINS_HOME} &&\
    addgroup --gid 1000 jenkins &&\
    adduser --system \
            --home ${JENKINS_HOME} \
    	    --uid 1000 \
	        --group 1000 \
	        --shell /bin/bash \
	        --disabled-login

# Now run as the jenkins user
USER jenkins

ENTRYPOINT  ["/docker-entrypoint.sh"]

# Final image with just the war added to /opt
# Having this as a separate build step will allow us to generate versioned
# builds with the same base image & just 1 layer being different - i.e.
# older known-good jenkins versions with just the JDK updated
FROM jenkins

COPY jenkins.war /opt/jenkins.war
