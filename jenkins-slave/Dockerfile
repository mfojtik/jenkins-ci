# The FROM will be replaced when building in OpenShift
FROM openshift/base-centos7

# Install Java to run slave.jar
USER root
RUN yum install -y --setopt=tsflags=nodocs --enablerepo=centosplus epel-release && \
    rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 && \
    yum install -y --setopt=tsflags=nodocs install java unifdef quilt nss_wrapper && \
    yum clean all && \
    mkdir /opt/app-root/jenkins && \
    chmod -R go+rwx /opt/app-root/jenkins

# Copy the entrypoint
COPY contrib/bin/* /usr/local/bin/
COPY contrib/openshift/passwd.template /opt/app-root/jenkins/
USER 1001

CMD ["/usr/local/bin/run-jenkins-slave"]
