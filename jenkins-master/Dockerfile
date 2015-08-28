FROM openshift/jenkins-1-centos7

# Install 'git' binary needed for the Github plugin
USER root
RUN yum install -y git
USER 1001

COPY plugins.txt /opt/openshift/configuration/plugins.txt
RUN /usr/local/bin/plugins.sh /opt/openshift/configuration/plugins.txt
