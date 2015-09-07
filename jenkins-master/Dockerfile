FROM openshift/jenkins-1-centos7

USER root
COPY contrib/bin/* /usr/local/bin/

RUN rm -rf /opt/openshift/configuration/jobs && \
    rm -rf /opt/openshift/configuration/config.xml

# Copy the Jenkins configuration and jobs to Jenkins config dir
COPY configuration/* /opt/openshift/configuration/

# Install the Jenkins plugin listed in 'plugins.txt'
RUN /usr/local/bin/plugins.sh /opt/openshift/configuration/plugins.txt && \
    chmod go+rw -R /opt/openshift

USER 1001
