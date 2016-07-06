#!/bin/ash
#
# Environment variables:
# MAVEN_MIRROR              The url of a local repository to use instead of maven central
# MAVEN_PRIVATE_MIRROR      Optional when MAVEN_MIRROR is in use, a secondary mirror
#
# MAVEN_RELEASE_ID          id
# MAVEN_RELEASE_USER        user for releases
# MAVEN_RELEASE_PASSWORD    password for releases
#
# MAVEN_SNAPSHOT_ID         id
# MAVEN_SNAPSHOT_USER       user for snapshots
# MAVEN_SNAPSHOT_PASSWORD   password for snapshots
#

# Maven config
if [ ! -f /home/jenkins/.m2/settings.xml ]
then
    mkdir -p /home/jenkins/.m2
    (
	echo '<?xml version="1.0" encoding="UTF-8"?>'
	echo '<settings xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">'

        echo '<servers>'
        if [ -n "$MAVEN_RELEASE_USER" ]
        then
            if [ -z "$MAVEN_RELEASE_ID" ]
            then
                MAVEN_RELEASE_ID=releases
            fi
            echo "<server><id>${MAVEN_SNAPSHOT_ID}</id><username>${MAVEN_RELEASE_USER}</username><password>${MAVEN_RELEASE_PASSWORD}</password></server>"
        fi
        if [ -n "$MAVEN_SNAPSHOT_USER" ]
        then
            if [ -z "$MAVEN_SNAPSHOT_ID" ]
            then
                MAVEN_SNAPSHOT_ID=snapshots
            fi
            echo "<server><id>${MAVEN_SNAPSHOT_ID}</id><username>${MAVEN_SNAPSHOT_USER}</username><password>${MAVEN_SNAPSHOT_PASSWORD}</password></server>"
        fi
        echo '</servers>'

	if [ -n "$MAVEN_MIRROR" ]
	then
	    MIRROR_OF=central
	    if [ -n "$MAVEN_PRIVATE_MIRROR" ]
	    then
		MIRROR_OF="${MIRROR_OF},!localMirror"
	    fi
	    echo '<mirrors>'
	    echo "<mirror><id>centralMirror</id><name>Local mirror of central</name><url>${MAVEN_MIRROR}</url><mirrorOf>${MIRROR_OF}</mirrorOf></mirror>"
	    echo '</mirrors>'

	    echo '<profiles>'
	    echo '<profile><id>centralMirror</id>'
	    echo '<repositories>'
	    echo '<repository><id>central</id><url>http://central</url><releases><enabled>true</enabled></releases><snapshots><enabled>true</enabled></snapshots></repository>'
	    if [ -n "$MAVEN_PRIVATE_MIRROR" ]
	    then
		echo "<repository><id>privateMirror</id><url>${MAVEN_PRIVATE_MIRROR}</url><releases><enabled>true</enabled></releases><snapshots><enabled>true</enabled></snapshots></repository>"
	    fi
	    echo '</repositories>'
	    echo '<pluginRepositories>'
	    echo '<pluginRepository><id>central</id><url>http://central</url><releases><enabled>true</enabled></releases><snapshots><enabled>true</enabled></snapshots></pluginRepository>'
	    if [ -n "$MAVEN_PRIVATE_MIRROR" ]
	    then
		echo "<pluginRepository><id>privateMirror</id><url>${MAVEN_PRIVATE_MIRROR}</url><releases><enabled>true</enabled></releases><snapshots><enabled>true</enabled></snapshots></pluginRepository>"
	    fi
	    echo '</pluginRepositories>'
	    echo '</profile>'
	    echo '</profiles>'
	    echo '<activeProfiles><activeProfile>centralMirror</activeProfile></activeProfiles>'
	fi
	echo '</settings>'
    ) >/home/jenkins/.m2/settings.xml

    mkdir -p /opt/jenkins/.m2
    cp /home/jenkins/.m2/settings.xml /opt/jenkins/.m2/settings.xml

    mkdir -p /root/.m2
    cp /home/jenkins/.m2/settings.xml /root/.m2/settings.xml

    chown -R jenkins:jenkins /home/jenkins/.m2
fi
