FROM openshift/jenkins-1-centos7

# Install 'git' binary needed for the Github plugin
USER root

# Install the Jenkins plugin listed in 'plugins.txt'
COPY plugins.txt /opt/openshift/configuration/plugins.txt
RUN /usr/local/bin/plugins.sh /opt/openshift/configuration/plugins.txt

# Cleanup the example job and copy new jobs
RUN rm -rf /opt/openshift/configuration/jobs/*
#COPY jobs/* /opt/openshift/configuration/jobs/

COPY contrib/bin/* /usr/local/bin/

RUN chmod go+rw -R /opt/openshift
USER 1001
