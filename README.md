A Jenkins server running the current war

Full documentationl: https://area51.onl/Docker/Jenkins

To add options to java when starting the server use -e JAVA_OPTS=
To add options to Jenkins use -e JENKINS_OPTS

Mountable volumes:
* /opt/jenkins - the directory where jenkins configuration is placed
* /var/run/docker.sock allows you to run docker commands within the server. Normally you'd run it with -e /var/run/docker.sock:/var/run/docker.sock and nothing else.
* /var/run/docker.sock allows you to run docker commands within the slave. Normally you'd run it with -e /var/run/docker.sock:/var/run/docker.sock and nothing else.
* When using docker you can get the container to log in (so you can deploy images from jobs) with -e DOCKER_USER=userOrOrganisation -e DOCKER_PASSWORD=password
* Optionally you can use a local docker repository when logging in by adding -e DOCKER_SERVER=hostname

JENKINS_PASSWORD=newpassword when running the image.


