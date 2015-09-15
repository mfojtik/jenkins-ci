# The FROM will be replaced when building in OpenShift
FROM openshift/base-centos7

# Install headless Java 
USER root
RUN yum install -y --setopt=tsflags=nodocs --enablerepo=centosplus epel-release && \
    rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 && \
    yum install -y --setopt=tsflags=nodocs install java-1.8.0-openjdk-headless unifdef quilt nss_wrapper && \
    yum clean all && \
    mkdir /opt/app-root/jenkins && \
    chmod -R go+rwx /opt/app-root/jenkins

# Copy the entrypoint
COPY contrib/openshift/* /opt/app-root/jenkins/
USER 1001
