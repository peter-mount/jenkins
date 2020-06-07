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

# Now retrieve the war for the required version
#
# This build stage retrieves the appropriate war and the entry point
# into /opt with appropriate permissions.
#
# It uses the base jdk image from the first stage to keep the final image clean
#
FROM jdk AS war
ARG version
COPY log.properties /deploy/
COPY docker-entrypoint.sh /deploy/
RUN URL=http://mirrors.jenkins-ci.org/war/${version}/jenkins.war &&\
    if [ "${version}" = "lts" ];\
    then\
        URL="http://mirrors.jenkins-ci.org/war-stable/latest/jenkins.war";\
    fi &&\
    curl -sSl -p /deploy/jenkins.war "${URL}" &&\
    find /deploy -type f -exec chmod 644 {} \; &&\
    chmod 500 /deploy/docker-entrypoint.sh \;

# Final image based on the jenkins build step with just the war added to /opt
# Having this as a separate build step will allow us to generate versioned
# builds with the same base image & just 1 layer being different - i.e.
# older known-good jenkins versions with just the JDK updated
FROM jenkins
COPY FROM war /deploy/ /opt/
ENTRYPOINT  ["/opt/docker-entrypoint.sh"]
