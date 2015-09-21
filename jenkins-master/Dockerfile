FROM openshift/jenkins-1-centos7

USER root
RUN rm -rf /opt/openshift/configuration/jobs && \
    rm -rf /opt/openshift/configuration/config.xml

# Copy the Jenkins configuration and jobs to Jenkins config dir
COPY configuration/ /opt/openshift/configuration/
ADD bin/setup-keystore.sh /usr/local/bin/setup-keystore.sh

# Install the Jenkins plugin listed in 'plugins.txt'
# Remove the bundled credentials plugin as we install more recent version
# via plugins.sh.
RUN /usr/local/bin/plugins.sh /opt/openshift/configuration/plugins.txt && \
    chmod go+rw -R /opt/openshift && \
    zip -d /usr/lib/jenkins/jenkins.war WEB-INF/plugins/credentials.hpi

USER 1001
CMD ["/usr/local/bin/setup-keystore.sh"]
