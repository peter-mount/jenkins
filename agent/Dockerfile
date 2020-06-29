# A docker slave based on docker-inbound-agent
FROM area51/jenkins:nowar AS agent

USER root
RUN apt-get update &&\
    apt-get install git-lfs &&\
    rm -rf /var/lib/apt/lists/* &&\
    curl --create-dirs -fsSLo /usr/share/jenkins/agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/4.3/remoting-4.3.jar &&\
    chmod 755 /usr/share/jenkins &&\
    chmod 644 /usr/share/jenkins/agent.jar &&\
    ln -sf /usr/share/jenkins/agent.jar /usr/share/jenkins/slave.jar

USER jenkins
ENV AGENT_WORKDIR=${JENKINS_HOME}/agent
RUN mkdir -pv ${AGENT_WORKDIR} ${JENKINS_HOME}/.jenkins
WORKDIR ${JENKINS_HOME}

FROM agent AS client

RUN cd /tmp &&\
    uname -m &&\
    curl -sSL -O https://download.docker.com/linux/static/stable/$(uname -m)/docker-19.03.12.tgz &&\
    tar xzf docker-19.03.12.tgz

FROM agent AS inbound

USER root
COPY agent/jenkins-agent.sh /usr/local/bin/jenkins-agent
COPY --from=client /tmp/docker/docker /usr/bin/docker

RUN chmod +x /usr/local/bin/jenkins-agent &&\
    ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave

USER jenkins

ENTRYPOINT ["jenkins-agent"]
