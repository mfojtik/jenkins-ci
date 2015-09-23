#!/bin/bash

# The directory that Jenkins will execute the builds and store cache files.
# The directory has to be writeable for the user that the container is running
# under.
export JENKINS_HOME=/opt/app-root/jenkins

# Setup nss_wrapper so the random user OpenShift will run this container
# has an entry in /etc/passwd.
# This is needed for 'git' and other tools to work properly.
#
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
envsubst < ${JENKINS_HOME}/passwd.template > ${JENKINS_HOME}/passwd
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=${JENKINS_HOME}/passwd
export NSS_WRAPPER_GROUP=/etc/group

# Make sure the Java clients have valid $HOME directory set
export HOME=${JENKINS_HOME}
# export _JAVA_OPTIONS=-Duser.home=${HOME}
