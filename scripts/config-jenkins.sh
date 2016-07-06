#!/bin/ash

# /opt/jenkins is available for the workspace work files
if [ ! -d /opt/jenkins ]
then
    mkdir -p /opt/jenkins
    chown jenkins:jenkins /opt/jenkins
fi

# If docker socket is present then ensure we have permission to access it
if [ -S /var/run/docker.sock ]
then
    gid=$(ls -ln /var/run/docker.sock | sed -re "s/ +/ /g" | cut -f4 -d' ')
    addgroup -g $gid docker 2>/dev/null
    gn=$(grep ":${gid}:" /etc/group|cut -f1 -d':')
    adduser root "$gn"
    adduser jenkins "$gn"
fi

# Bug JENKINS-32542 I found I hit this bug suddenly then found JENKINS-29674 mentioned
# about the loopback used by maven and the slave. Adding this seems (as I write this)
# to fix this bug.
#
# Now we have to do this at container startup as the host file is replaced by docker
# everytime the container is started.
echo "127.0.0.1 dockerhost" >>/etc/hosts