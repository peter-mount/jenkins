# Dockerfile for a Jenkins container

# This build stage retrieves the appropriate war and the entry point
# into /opt with appropriate permissions.
FROM area51/jenkins:nowar AS war
ARG version
USER root
COPY log.properties /deploy/jenkins-deploy/
COPY docker-entrypoint.sh /deploy/jenkins-deploy/
COPY retrieve-jenkins.sh /bin/
RUN retrieve-jenkins.sh ${version} /deploy/jenkins-deploy/jenkins.war &&\
    chown -R jenkins:jenkins /deploy &&\
    find /deploy -type f -exec chmod 644 {} \; &&\
    chmod 555 /deploy/jenkins-deploy/docker-entrypoint.sh

# Final image based on the jenkins build step with just the war added to /opt
# Having this as a separate build step will allow us to generate versioned
# builds with the same base image & just 1 layer being different - i.e.
# older known-good jenkins versions with just the JDK updated
FROM area51/jenkins:nowar
COPY --from=war /deploy/ /opt/
ENTRYPOINT  ["/opt/jenkins-deploy/docker-entrypoint.sh"]
