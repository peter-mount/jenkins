#!/bin/bash
#
# Retrieves the required version of jenkins.war
#
version=$1
dest=$2

dir=war
if [ "${version}" = "lts" ]
then
  version=latest
  dir=war-stable
fi

path=${dir}/${version}/jenkins.war
echo "Retrieving ${path} -> ${dest}"
curl -sSl -o $dest http://mirrors.jenkins-ci.org/${path}
