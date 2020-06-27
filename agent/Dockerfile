# A docker slave based on docker-inbound-agent
FROM area51/jenkins:nowar AS agent
ARG VERSION=4.3

USER root
RUN apt-get update &&\
    apt-get install git-lfs &&\
    rm -rf /var/lib/apt/lists/* &&\
    curl --create-dirs -fsSLo /usr/share/jenkins/agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar &&\
    chmod 755 /usr/share/jenkins &&\
    chmod 644 /usr/share/jenkins/agent.jar &&\
    ln -sf /usr/share/jenkins/agent.jar /usr/share/jenkins/slave.jar

USER jenkins
ENV AGENT_WORKDIR=${JENKINS_HOME}/agent
RUN mkdir -pv ${AGENT_WORKDIR} ${JENKINS_HOME}/.jenkins
WORKDIR ${JENKINS_HOME}

FROM agent AS client

RUN cd /tmp &&\
    curl -sSL -O https://master.dockerproject.org/linux/x86_64/docker.tgz &&\
    tar xzf docker.tgz

FROM agent AS inbound

USER root
COPY agent/jenkins-agent.sh /usr/local/bin/jenkins-agent
COPY --from=client /tmp/docker /usr/local/docker

RUN chmod +x /usr/local/bin/jenkins-agent &&\
    ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave &&\
    ln -s /usr/local/docker/docker /usr/bin/docker &&\
    echo "docker:x:998:jenkins" >>/etc/group

USER jenkins

ENTRYPOINT ["jenkins-agent"]
