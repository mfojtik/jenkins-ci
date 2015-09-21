FROM openshift/jenkins-1-centos7

USER root
RUN rm -rf /opt/openshift/configuration/jobs && \
    rm -rf /opt/openshift/configuration/config.xml

# Copy the Jenkins configuration and jobs to Jenkins config dir
COPY configuration/ /opt/openshift/configuration/
ADD bin/setup-and-run-jenkins.sh /usr/local/bin/setup-and-run-jenkins.sh

# Install the Jenkins plugin listed in 'plugins.txt'
# Prevent credentials plugin to be overiden by bundled plugin.
RUN /usr/local/bin/plugins.sh /opt/openshift/configuration/plugins.txt && \
    touch /opt/openshift/plugins/credentials.jpi.pinned && \
    chmod go+rw -R /opt/openshift && \
    yum install -y gettext && yum clean all

USER 1001

# Override the default entrypoint
ENTRYPOINT []
CMD ["/usr/local/bin/setup-and-run-jenkins.sh"]
