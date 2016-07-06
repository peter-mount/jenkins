FROM area51/docker-client
MAINTAINER Peter Mount <peter@retep.org>

ENV JENKINS_HOME /opt/jenkins
ENV JENKINS_PORT 80

COPY keys/* /etc/ssh.cache/

COPY *.sh /

RUN chmod 500 /docker-entrypoint.sh &&\
    chmod -f 600 /etc/ssh.cache/ssh_host_* &&\
    mkdir -p ~root/.ssh &&\
    chmod 700 ~root/.ssh/ &&\
    echo -e "Port 22\n" >> /etc/ssh/sshd_config &&\
    cp -a /etc/ssh /etc/ssh.cache && \
    mkdir -p /var/run/sshd &&\
    addgroup -g 1000 jenkins &&\
    adduser -h /home/jenkins \
    	    -u 1000 \
	    -G jenkins \
	    -s /bin/ash \
	    -D jenkins &&\
    echo "jenkins:${jenkins.password}" | chpasswd &&\
    apk add --update \
        git \
        mercurial \
        subversion &&\
    echo Retrieving jenkins &&\
    curl -sSL -O ${jenkins.repo}/war/latest/jenkins.war &&\
    mv jenkins.war /opt &&\
    mkdir ${JENKINS_HOME} &&\
    rm -rf /var/cache/apk/*

EXPOSE 22/tcp 80/tcp 443/tcp 50000/tcp

VOLUME ${JENKINS_HOME}

ENTRYPOINT  ["/docker-entrypoint.sh"]

