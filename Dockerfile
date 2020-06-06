# Docker file to build the jenkins container used by the Area51 project

FROM adoptopenjdk/openjdk8:alpine-slim AS jdk
MAINTAINER Peter Mount <peter@area51.dev>

# Add the common source control apps
RUN apk add --no-cache \
        git \
        mercurial \
        subversion

# Now add the jenkins user & startup script
FROM jdk AS jenkins

ENV JENKINS_HOME /opt/jenkins
ENV JENKINS_PORT 80

# Startup script & logging template
COPY docker-entrypoint.sh /
COPY log.properties /

RUN chmod 500 /docker-entrypoint.sh &&\
    addgroup -g 1000 jenkins &&\
    adduser -h /home/jenkins \
    	    -u 1000 \
	    -G jenkins \
	    -s /bin/ash \
	    -D jenkins &&\
    mkdir ${JENKINS_HOME}

ENTRYPOINT  ["/docker-entrypoint.sh"]

EXPOSE 80/tcp 443/tcp 50000/tcp

# Final image with just the war
FROM jdk

COPY jenkins.war /opt/jenkins.war
