FROM openshift/jenkins-1-centos7

USER root
RUN rm -rf /opt/openshift/configuration/jobs && \
    rm -rf /opt/openshift/configuration/config.xml

# Copy the Jenkins configuration and jobs to Jenkins config dir
COPY configuration/ /opt/openshift/configuration/
COPY bin/* /usr/local/bin/

# Install the Jenkins plugin listed in 'plugins.txt'
# Prevent credentials plugin to be overiden by bundled plugin.
# The gettext is needed to provide envsubst command.
RUN /usr/local/bin/plugins.sh /opt/openshift/configuration/plugins.txt && \
    touch /opt/openshift/plugins/credentials.jpi.pinned && \
    touch /opt/openshift/plugins/git.jpi.pinned && \
    touch /opt/openshift/plugins/git-client.jpi.pinned && \
    chown -R 1001:0 /opt/openshift && chmod -R g+w /opt/openshift/configuration

USER 1001

# Override the default entrypoint
CMD ["/usr/local/bin/setup-and-run-jenkins.sh"]
