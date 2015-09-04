FROM openshift/jenkins-1-centos7

USER root
COPY contrib/bin/* /usr/local/bin/
#COPY jobs/* /opt/openshift/configuration/jobs/

# Install the Jenkins plugin listed in 'plugins.txt'
COPY plugins.txt /opt/openshift/configuration/plugins.txt
RUN /usr/local/bin/plugins.sh /opt/openshift/configuration/plugins.txt && \
    rm -rf /opt/openshift/configuration/jobs/* && \
    chmod go+rw -R /opt/openshift

USER 1001
