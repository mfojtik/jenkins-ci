# The FROM will be replaced when building in OpenShift
#FROM openshift/base-centos7
FROM openshift/ruby-20-centos7
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Install Java to run slave.jar
USER root
RUN yum -y install java unifdef quilt && \
    yum clean all && \
    mkdir /opt/app-root/jenkins && chmod -R go+rwx /opt/app-root/jenkins

# Copy the entrypoint
COPY contrib/bin/* /usr/local/bin/
USER 1001

CMD ["/usr/local/bin/run-jenkins-slave"]
